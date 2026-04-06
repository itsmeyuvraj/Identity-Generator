import SwiftUI
import AppKit
import UserNotifications

@MainActor
final class PersonaViewModel: ObservableObject {

    // MARK: - Published State

    @Published var personaName: String       = ""
    @Published var personaEmail: String      = ""
    @Published var messages: [Message]       = []
    @Published var selectedMessage: MessageDetail? = nil
    @Published var isGenerating: Bool        = false
    @Published var errorMessage: String?     = nil

    // MARK: - Private

    private var token: String?              = nil
    private var pollingTask: Task<Void, Never>? = nil
    private var generation: Int             = 0     // Guards against stale polling updates

    // MARK: - Init

    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        Task { await generatePersona() }
    }

    // MARK: - Persona Generation

    func generatePersona() async {
        guard !isGenerating else { return }

        isGenerating = true
        errorMessage = nil

        // Cancel previous polling and clear stale data
        generation &+= 1
        let myGeneration = generation
        pollingTask?.cancel()
        pollingTask = nil

        withAnimation(.easeInOut(duration: 0.3)) {
            messages = []
            selectedMessage = nil
        }

        // Show name immediately — no network needed
        let (first, last) = PersonaGenerator.generateName()
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
            personaName  = "\(first) \(last)"
            personaEmail = ""
        }

        do {
            let domain = try await MailTMService.shared.getActiveDomain()
            let (email, password) = PersonaGenerator.generateEmail(first: first, last: last, domain: domain)
            let _ = try await MailTMService.shared.createAccount(address: email, password: password)
            let newToken = try await MailTMService.shared.getToken(address: email, password: password)

            token = newToken
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                personaEmail = email
                isGenerating = false
            }

            copyEmailToClipboard()
            startPolling(generation: myGeneration)

        } catch {
            withAnimation {
                errorMessage = error.localizedDescription
                isGenerating = false
            }
        }
    }

    // MARK: - Clipboard

    func copyEmailToClipboard() {
        guard !personaEmail.isEmpty else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(personaEmail, forType: .string)
    }

    // MARK: - Message Detail

    func loadMessageDetail(id: String) async {
        guard let token = token else { return }
        do {
            let detail = try await MailTMService.shared.getMessage(id: id, token: token)
            withAnimation(.easeInOut(duration: 0.25)) {
                selectedMessage = detail
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearMessageDetail() {
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedMessage = nil
        }
    }

    // MARK: - Notifications

    private func sendNotification(subject: String, from: String) {
        let content = UNMutableNotificationContent()
        content.title = "New Email"
        content.subtitle = "From: \(from)"
        content.body = subject
        content.sound = .default
        let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(req)
    }

    // MARK: - Polling

    private func startPolling(generation: Int) {
        // The Task inherits @MainActor isolation from its creation context,
        // so all self.* accesses (before and after awaits) are safe and do
        // NOT require `await`.
        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { break }

                // Capture actor-isolated values synchronously before any await
                let tok = self.token
                let gen = self.generation
                guard let tok, gen == generation else { break }

                do {
                    let fetched = try await MailTMService.shared.getMessages(token: tok)
                    // Back on @MainActor after await; re-check generation
                    if !Task.isCancelled, self.generation == generation {
                        let newOnes = fetched.filter { msg in !self.messages.contains(where: { $0.id == msg.id }) }
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.messages = fetched
                        }
                        for msg in newOnes {
                            self.sendNotification(subject: msg.subject, from: msg.from.name ?? msg.from.address)
                        }
                    }
                } catch {
                    if self.generation == generation {
                        withAnimation { self.errorMessage = error.localizedDescription }
                    }
                }
                // Wait 7 seconds; CancellationError is swallowed intentionally
                try? await Task.sleep(nanoseconds: 7_000_000_000)
            }
        }
    }
}

import SwiftUI
import AppKit
import UserNotifications

@MainActor
final class PersonaViewModel: ObservableObject {

    // MARK: - Published State

    @Published var personaName: String          = ""
    @Published var personaEmail: String         = ""
    @Published var messages: [MailMessage]      = []
    @Published var selectedMessage: MailMessage? = nil
    @Published var isGenerating: Bool           = false
    @Published var errorMessage: String?        = nil
    @Published var provider: EmailProvider      = .guerrillaMail

    // MARK: - Private

    private var session: ProviderSession?       = nil
    private var pollingTask: Task<Void, Never>? = nil
    private var generation: Int                 = 0

    // MARK: - Init

    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        Task { await generatePersona() }
    }

    // MARK: - Provider Switch

    func switchProvider(_ newProvider: EmailProvider) {
        guard newProvider != provider else { return }
        provider = newProvider
        Task { await generatePersona() }
    }

    // MARK: - Persona Generation

    func generatePersona() async {
        guard !isGenerating else { return }

        isGenerating = true
        errorMessage = nil

        generation &+= 1
        let myGeneration = generation
        pollingTask?.cancel()
        pollingTask = nil

        withAnimation(.easeInOut(duration: 0.3)) {
            messages = []
            selectedMessage = nil
        }

        // Show name immediately
        let (first, last) = PersonaGenerator.generateName()
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
            personaName  = "\(first) \(last)"
            personaEmail = ""
        }

        let currentProvider = provider
        do {
            let newSession = try await MailTMService.shared.createSession(provider: currentProvider)
            session = newSession

            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                personaEmail = newSession.email
                isGenerating = false
            }

            copyEmailToClipboard()
            startPolling(generation: myGeneration, provider: currentProvider)

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
        guard let session else { return }
        do {
            let detail = try await MailTMService.shared.getMessage(id: id, session: session, provider: provider)
            withAnimation(.easeInOut(duration: 0.25)) { selectedMessage = detail }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearMessageDetail() {
        withAnimation(.easeInOut(duration: 0.25)) { selectedMessage = nil }
    }

    // MARK: - Notifications

    private func sendNotification(subject: String, from: String) {
        let content = UNMutableNotificationContent()
        content.title = "New Email"
        content.subtitle = "From: \(from)"
        content.body = subject
        content.sound = .default
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        )
    }

    // MARK: - Polling

    private func startPolling(generation: Int, provider: EmailProvider) {
        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { break }

                let sess = self.session
                let gen  = self.generation
                guard let sess, gen == generation else { break }

                do {
                    let fetched = try await MailTMService.shared.getMessages(session: sess, provider: provider)
                    if !Task.isCancelled, self.generation == generation {
                        let newOnes = fetched.filter { msg in
                            !self.messages.contains(where: { $0.id == msg.id })
                        }
                        withAnimation(.easeInOut(duration: 0.2)) { self.messages = fetched }
                        for msg in newOnes { self.sendNotification(subject: msg.subject, from: msg.from) }
                    }
                } catch {
                    if self.generation == generation {
                        withAnimation { self.errorMessage = error.localizedDescription }
                    }
                }

                try? await Task.sleep(nanoseconds: 7_000_000_000)
            }
        }
    }
}

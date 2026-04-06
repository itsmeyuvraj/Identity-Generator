import SwiftUI
import AppKit

struct PersonaCardView: View {

    let name: String
    let email: String
    let isGenerating: Bool
    let onCopy: () -> Void
    let onRefresh: () -> Void

    @State private var showNameCopied  = false
    @State private var showEmailCopied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerRow
            Divider().overlay(Color.white.opacity(0.10))
            emailRow
            actionRow
        }
        .padding(15)
        .background(cardBackground)
    }

    // MARK: - Subviews

    private var headerRow: some View {
        HStack(spacing: 11) {
            avatarBadge
            nameBlock
            Spacer()
            statusDot
        }
    }

    private var avatarBadge: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.45, green: 0.22, blue: 0.95),
                            Color(red: 0.15, green: 0.35, blue: 0.92)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 38, height: 38)
                .shadow(color: Color(red: 0.4, green: 0.2, blue: 0.9).opacity(0.5), radius: 6)

            Text(initials)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
    }

    private var nameBlock: some View {
        VStack(alignment: .leading, spacing: 2) {
            if isGenerating {
                HStack(spacing: 5) {
                    ProgressView()
                        .scaleEffect(0.55)
                        .tint(.white.opacity(0.6))
                    Text("Generating…")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.55))
                }
            } else {
                HStack(spacing: 5) {
                    Button(action: handleNameCopy) {
                        Text(name.isEmpty ? "—" : name)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(showNameCopied ? Color.green : .white)
                            .animation(.spring(response: 0.25), value: showNameCopied)
                    }
                    .buttonStyle(.plain)
                    .help("Copy name")
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal:   .opacity.combined(with: .move(edge: .bottom))
                    ))
                    .id("name-\(name)")

                    if !name.isEmpty {
                        Image(systemName: showNameCopied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(showNameCopied ? Color.green : Color.white.opacity(0.45))
                            .animation(.spring(response: 0.25), value: showNameCopied)
                    }
                }

                Text("Disposable Identity")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.38))
                    .tracking(0.5)
            }
        }
    }

    private var statusDot: some View {
        Group {
            if !isGenerating {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.28))
                        .frame(width: 14, height: 14)
                    Circle()
                        .fill(Color.green)
                        .frame(width: 7, height: 7)
                }
            }
        }
    }

    private var emailRow: some View {
        HStack(spacing: 7) {
            Image(systemName: "envelope.fill")
                .font(.system(size: 10))
                .foregroundStyle(Color.white.opacity(0.40))

            Text(email.isEmpty ? "—" : email)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.white.opacity(0.75))
                .lineLimit(1)
                .truncationMode(.middle)
                .transition(.opacity)
                .id("email-\(email)")

            Spacer()

            if showEmailCopied {
                Text("Copied!")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.green)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
        }
    }

    private var actionRow: some View {
        HStack(spacing: 8) {
            GlassButton(
                title: showEmailCopied ? "Copied!" : "Copy Email",
                icon:  showEmailCopied ? "checkmark" : "doc.on.doc.fill",
                action: handleEmailCopy,
                style: .normal
            )

            GlassButton(
                title: "Generate Email",
                icon:  "arrow.clockwise",
                action: onRefresh,
                style: .destructive
            )
        }
    }

    private var cardBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.075))

            // Specular top-glass band
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.13), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                )

            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.13), lineWidth: 0.6)
        }
        .shadow(color: Color.black.opacity(0.35), radius: 12, y: 6)
    }

    // MARK: - Helpers

    private var initials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2,
           let f = parts.first?.first,
           let l = parts.last?.first {
            return "\(f)\(l)"
        }
        return name.prefix(1).uppercased()
    }

    private func handleNameCopy() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(name, forType: .string)
        withAnimation(.spring(response: 0.3)) { showNameCopied = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation { showNameCopied = false }
        }
    }

    private func handleEmailCopy() {
        onCopy()
        withAnimation(.spring(response: 0.3)) { showEmailCopied = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation { showEmailCopied = false }
        }
    }
}

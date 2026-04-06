import SwiftUI

// MARK: - InboxView

struct InboxView: View {

    let messages: [Message]
    let onSelect: (String) async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            inboxHeader
            Divider().overlay(Color.white.opacity(0.08))

            if messages.isEmpty {
                emptyState
            } else {
                messageList
            }
        }
    }

    // MARK: - Header

    private var inboxHeader: some View {
        HStack(spacing: 6) {
            Image(systemName: "tray.fill")
                .font(.system(size: 11))
                .foregroundStyle(Color.white.opacity(0.40))

            Text("INBOX")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.white.opacity(0.40))
                .tracking(1.8)

            Spacer()

            if !messages.isEmpty {
                Text("\(messages.count)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.85))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color(red: 0.38, green: 0.18, blue: 0.88).opacity(0.55))
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 7) {
            Image(systemName: "tray")
                .font(.system(size: 26))
                .foregroundStyle(Color.white.opacity(0.18))

            Text("No messages yet")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.28))

            Text("Polling every 7 seconds…")
                .font(.system(size: 10))
                .foregroundStyle(Color.white.opacity(0.18))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
    }

    // MARK: - Message List

    private var messageList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(messages) { msg in
                    MessageRowView(message: msg) {
                        Task { await onSelect(msg.id) }
                    }
                }
            }
        }
    }
}

// MARK: - MessageRowView

struct MessageRowView: View {

    let message: Message
    let onTap: () -> Void

    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top) {
                        // Unread indicator
                        Circle()
                            .fill(message.isRead ? Color.clear : Color(red: 0.5, green: 0.3, blue: 1.0))
                            .frame(width: 6, height: 6)
                            .padding(.top, 3)

                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text(senderDisplay)
                                    .font(.system(size: 12, weight: message.isRead ? .regular : .semibold))
                                    .foregroundStyle(Color.white.opacity(message.isRead ? 0.65 : 0.92))
                                    .lineLimit(1)

                                Spacer()

                                Text(relativeDate(message.createdAt))
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color.white.opacity(0.35))
                            }

                            Text(message.subject)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Color.white.opacity(0.65))
                                .lineLimit(1)

                            if let intro = message.intro, !intro.isEmpty {
                                Text(intro)
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color.white.opacity(0.38))
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    isHovered
                        ? Color.white.opacity(0.07)
                        : Color.clear
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .onHover { h in
                withAnimation(.easeInOut(duration: 0.12)) { isHovered = h }
            }

            // Glass divider
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.clear, Color.white.opacity(0.07), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 0.5)
                .padding(.horizontal, 16)
        }
    }

    // MARK: Helpers

    private var senderDisplay: String {
        let n = message.from.name ?? ""
        return n.isEmpty ? message.from.address : n
    }

    private func relativeDate(_ iso: String) -> String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = f.date(from: iso) else { return "" }
        let rel = RelativeDateTimeFormatter()
        rel.unitsStyle = .abbreviated
        return rel.localizedString(for: date, relativeTo: Date())
    }
}

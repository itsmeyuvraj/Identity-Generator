import SwiftUI

struct MessageDetailView: View {

    let detail: MessageDetail
    let onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            topBar
            Divider().overlay(Color.white.opacity(0.08))
            scrollBody
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button(action: onBack) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 11, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(Color.white.opacity(0.65))
            }
            .buttonStyle(.plain)

            Spacer()

            Text(relativeDate(detail.createdAt))
                .font(.system(size: 10))
                .foregroundStyle(Color.white.opacity(0.35))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
    }

    // MARK: - Body

    private var scrollBody: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {

                // ── From ─────────────────────────────────────────────────
                metaRow(label: "From", value: fromDisplay)

                // ── Subject ──────────────────────────────────────────────
                Text(detail.subject)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Divider().overlay(Color.white.opacity(0.08))

                // ── Body ─────────────────────────────────────────────────
                Text(detail.bodyText)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.white.opacity(0.78))
                    .lineSpacing(5)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
        }
    }

    // MARK: - Helpers

    private func metaRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("\(label):")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.40))
                .frame(width: 34, alignment: .leading)

            Text(value)
                .font(.system(size: 11))
                .foregroundStyle(Color.white.opacity(0.75))
                .lineLimit(2)
        }
    }

    private var fromDisplay: String {
        let n = detail.from.name ?? ""
        let a = detail.from.address
        return n.isEmpty ? a : "\(n) <\(a)>"
    }

    private func relativeDate(_ iso: String) -> String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = f.date(from: iso) else { return "" }
        let rel = RelativeDateTimeFormatter()
        rel.unitsStyle = .short
        return rel.localizedString(for: date, relativeTo: Date())
    }
}

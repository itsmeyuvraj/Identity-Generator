import SwiftUI

struct ServicePickerView: View {

    let current: EmailProvider
    let onSelect: (EmailProvider) -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            // Tap outside to dismiss
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            VStack(alignment: .leading, spacing: 4) {
                // Header
                HStack {
                    Text("EMAIL SERVICE")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.white.opacity(0.35))
                        .tracking(1.5)
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color.white.opacity(0.30))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 6)

                Divider().overlay(Color.white.opacity(0.08))

                // Service rows
                ForEach(EmailProvider.allCases) { provider in
                    ServiceRow(
                        provider: provider,
                        isSelected: provider == current,
                        onTap: {
                            onSelect(provider)
                            onClose()
                        }
                    )
                }

                Spacer(minLength: 8)
            }
            .frame(width: 310)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(red: 0.07, green: 0.04, blue: 0.20).opacity(0.88))
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.12), lineWidth: 0.6)
                }
            )
            .shadow(color: .black.opacity(0.4), radius: 16, y: 6)
            .padding(.top, 46)   // sit just below the app bar
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - ServiceRow

private struct ServiceRow: View {

    let provider: EmailProvider
    let isSelected: Bool
    let onTap: () -> Void

    @State private var isHovered = false

    var accentColor: Color {
        let c = provider.accentColor
        return Color(red: c.r, green: c.g, blue: c.b)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 11) {
                // Icon badge
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(isSelected ? 0.28 : 0.12))
                        .frame(width: 32, height: 32)
                    Image(systemName: provider.icon)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(accentColor.opacity(isSelected ? 1.0 : 0.55))
                }

                // Labels
                VStack(alignment: .leading, spacing: 1) {
                    Text(provider.rawValue)
                        .font(.system(size: 12, weight: isSelected ? .semibold : .medium))
                        .foregroundStyle(Color.white.opacity(isSelected ? 0.95 : 0.65))
                    Text(provider.description)
                        .font(.system(size: 10))
                        .foregroundStyle(Color.white.opacity(0.35))
                }

                Spacer()

                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(accentColor)
                } else {
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        .frame(width: 14, height: 14)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 9)
                    .fill(isHovered ? Color.white.opacity(0.06) : Color.clear)
                    .padding(.horizontal, 6)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { h in withAnimation(.easeInOut(duration: 0.12)) { isHovered = h } }
    }
}

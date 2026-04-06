import SwiftUI

// MARK: - GlassButton

struct GlassButton: View {

    let title: String
    let icon: String
    let action: () -> Void
    var style: GlassButtonStyle = .normal

    @State private var isPressed = false

    var body: some View {
        Button(action: fireAction) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundStyle(style.foreground)
            .padding(.horizontal, 13)
            .padding(.vertical, 7)
            .background(buttonBackground)
            .scaleEffect(isPressed ? 0.94 : 1.0)
            .shadow(
                color: style == .destructive
                    ? Color.red.opacity(0.25)
                    : Color.black.opacity(0.28),
                radius: isPressed ? 2 : 6,
                y: isPressed ? 1 : 3
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.22, dampingFraction: 0.65), value: isPressed)
    }

    // MARK: Private

    private func fireAction() {
        isPressed = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            isPressed = false
        }
        action()
    }

    private var buttonBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9)
                .fill(style.fill)
            // Top-glass specular highlight
            RoundedRectangle(cornerRadius: 9)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.12), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
            RoundedRectangle(cornerRadius: 9)
                .stroke(style.border, lineWidth: 0.5)
        }
    }
}

// MARK: - Style

enum GlassButtonStyle {
    case normal, destructive, accent

    var foreground: AnyShapeStyle {
        switch self {
        case .normal:      return AnyShapeStyle(Color.white.opacity(0.88))
        case .destructive: return AnyShapeStyle(Color(red: 1.0, green: 0.42, blue: 0.42))
        case .accent:      return AnyShapeStyle(Color(red: 0.72, green: 0.55, blue: 1.0))
        }
    }

    var fill: Color {
        switch self {
        case .normal:      return Color.white.opacity(0.09)
        case .destructive: return Color(red: 1.0, green: 0.18, blue: 0.18).opacity(0.14)
        case .accent:      return Color(red: 0.40, green: 0.18, blue: 0.90).opacity(0.20)
        }
    }

    var border: Color {
        switch self {
        case .normal:      return Color.white.opacity(0.15)
        case .destructive: return Color(red: 1.0, green: 0.40, blue: 0.40).opacity(0.30)
        case .accent:      return Color(red: 0.55, green: 0.30, blue: 1.0).opacity(0.40)
        }
    }
}

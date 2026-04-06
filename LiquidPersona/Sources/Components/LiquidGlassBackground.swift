import SwiftUI

/// A continuously animating liquid-glass background made of flowing colour orbs
/// layered under a thin material.  Pauses automatically when not on screen.
struct LiquidGlassBackground: View {

    @State private var isVisible = false

    var body: some View {
        Group {
            if isVisible {
                TimelineView(.animation) { tl in
                    let t = tl.date.timeIntervalSinceReferenceDate
                    canvas(t: t)
                }
            } else {
                staticCanvas
            }
        }
        .onAppear  { isVisible = true  }
        .onDisappear { isVisible = false }
    }

    // MARK: - Static fallback (shown before first appear)

    private var staticCanvas: some View {
        LinearGradient(
            colors: [
                Color(red: 0.04, green: 0.04, blue: 0.18),
                Color(red: 0.08, green: 0.04, blue: 0.22),
                Color(red: 0.12, green: 0.06, blue: 0.28)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Animated Canvas

    @ViewBuilder
    private func canvas(t: Double) -> some View {
        ZStack {
            // ── Base deep space gradient ──────────────────────────────────
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.04, blue: 0.18),
                    Color(red: 0.08, green: 0.04, blue: 0.22),
                    Color(red: 0.12, green: 0.06, blue: 0.28)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // ── Orb 1 – deep violet, slow drift ──────────────────────────
            orb(
                color: Color(red: 0.35, green: 0.10, blue: 0.85),
                opacity: 0.55,
                radius: 160,
                size:   320,
                dx: sin(t * 0.28) * 85,
                dy: cos(t * 0.19) * 65
            )

            // ── Orb 2 – royal blue, medium speed ─────────────────────────
            orb(
                color: Color(red: 0.05, green: 0.30, blue: 0.92),
                opacity: 0.45,
                radius: 130,
                size:   260,
                dx: cos(t * 0.22) * 95,
                dy: sin(t * 0.31) * 75
            )

            // ── Orb 3 – indigo-pink accent ────────────────────────────────
            orb(
                color: Color(red: 0.60, green: 0.15, blue: 0.70),
                opacity: 0.30,
                radius:  90,
                size:   180,
                dx: sin(t * 0.37 + 1.2) * 70,
                dy: cos(t * 0.27 + 0.8) * 80
            )

            // ── Specular shimmer – small bright white orb ─────────────────
            orb(
                color: .white,
                opacity: 0.18,
                radius:  60,
                size:   120,
                dx: sin(t * 0.42 + 2.0) * 55,
                dy: cos(t * 0.34 + 1.4) * 45 - 55
            )
        }
    }

    // MARK: - Helper

    private func orb(
        color: Color,
        opacity: Double,
        radius: CGFloat,
        size: CGFloat,
        dx: CGFloat,
        dy: CGFloat
    ) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [color.opacity(opacity), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: radius
                )
            )
            .frame(width: size, height: size)
            .offset(x: dx, y: dy)
    }
}

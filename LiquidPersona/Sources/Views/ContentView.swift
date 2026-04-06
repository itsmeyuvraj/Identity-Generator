import SwiftUI
import AppKit

struct ContentView: View {

    @EnvironmentObject private var vm: PersonaViewModel
    @State private var showAbout        = false
    @State private var showServicePicker = false

    var body: some View {
        ZStack {
            // Layer 1 ── Animated liquid background
            LiquidGlassBackground()
                .ignoresSafeArea()

            // Layer 2 ── Frosted glass material
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            // Layer 3 ── Content
            ZStack {
                if let detail = vm.selectedMessage {
                    MessageDetailView(detail: detail, onBack: vm.clearMessageDetail)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal:   .move(edge: .trailing).combined(with: .opacity)
                        ))
                } else {
                    mainView
                        .transition(.opacity)
                }

                // Overlays (above content)
                if showServicePicker {
                    ServicePickerView(
                        current: vm.provider,
                        onSelect: { vm.switchProvider($0) },
                        onClose: { withAnimation(.easeInOut(duration: 0.18)) { showServicePicker = false } }
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .zIndex(10)
                }

                if showAbout {
                    AboutView(onClose: { withAnimation(.easeInOut(duration: 0.2)) { showAbout = false } })
                        .transition(.opacity)
                        .zIndex(11)
                }
            }
            .animation(.easeInOut(duration: 0.28), value: vm.selectedMessage?.id)
        }
        .frame(width: 350, height: 480)
    }

    // MARK: - Main View

    private var mainView: some View {
        VStack(spacing: 0) {
            appBar
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 10)

            PersonaCardView(
                name:         vm.personaName,
                email:        vm.personaEmail,
                isGenerating: vm.isGenerating,
                onCopy:       vm.copyEmailToClipboard,
                onRefresh:    { Task { await vm.generatePersona() } }
            )
            .padding(.horizontal, 12)
            .animation(.spring(response: 0.45, dampingFraction: 0.75), value: vm.personaName)

            if let err = vm.errorMessage {
                errorBanner(err)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            InboxView(
                messages: vm.messages,
                onSelect: vm.loadMessageDetail
            )
            .padding(.top, 6)

            Spacer(minLength: 0)
        }
    }

    // MARK: - App Bar

    private var appBar: some View {
        HStack(spacing: 8) {
            // Icon + title
            HStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.40, green: 0.18, blue: 0.88),
                                    Color(red: 0.10, green: 0.32, blue: 0.90)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 22, height: 22)

                    Image(systemName: "person.badge.key.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                }

                Text("Identity Generator")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.90))
            }

            Spacer()

            // Service picker chip
            Button(action: {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                    showServicePicker.toggle()
                    if showServicePicker { showAbout = false }
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: vm.provider.icon)
                        .font(.system(size: 9, weight: .medium))
                    Text(vm.provider.shortName)
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                    Image(systemName: showServicePicker ? "chevron.up" : "chevron.down")
                        .font(.system(size: 8, weight: .bold))
                }
                .foregroundStyle(providerColor.opacity(0.90))
                .padding(.horizontal, 7)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(providerColor.opacity(0.15))
                        .overlay(Capsule().stroke(providerColor.opacity(0.30), lineWidth: 0.5))
                )
            }
            .buttonStyle(.plain)
            .help("Switch email service")

            // About button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showAbout = true
                    showServicePicker = false
                }
            }) {
                Image(systemName: "info.circle")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.white.opacity(0.35))
            }
            .buttonStyle(.plain)
            .help("About")

            // Quit button
            Button(action: { NSApp.terminate(nil) }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.white.opacity(0.25))
            }
            .buttonStyle(.plain)
            .help("Quit Identity Generator")
        }
    }

    private var providerColor: Color {
        let c = vm.provider.accentColor
        return Color(red: c.r, green: c.g, blue: c.b)
    }

    // MARK: - Error Banner

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 11))
                .foregroundStyle(Color(red: 1.0, green: 0.55, blue: 0.30))

            Text(message)
                .font(.system(size: 11))
                .foregroundStyle(Color(red: 1.0, green: 0.55, blue: 0.30))
                .lineLimit(2)

            Spacer()

            Button(action: { withAnimation { vm.errorMessage = nil } }) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.40))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 9)
                .fill(Color(red: 1.0, green: 0.35, blue: 0.15).opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(Color(red: 1.0, green: 0.45, blue: 0.20).opacity(0.25), lineWidth: 0.5)
                )
        )
    }
}

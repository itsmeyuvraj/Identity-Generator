import SwiftUI

struct AboutView: View {

    let onClose: () -> Void

    var body: some View {
        ZStack {
            // Dim backdrop
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            // Card
            VStack(spacing: 0) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.42, green: 0.14, blue: 0.90),
                                    Color(red: 0.10, green: 0.38, blue: 0.94)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .shadow(color: Color(red: 0.4, green: 0.2, blue: 0.9).opacity(0.5), radius: 10)

                    Image(systemName: "person.badge.key.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.white)
                }
                .padding(.top, 28)

                Text("Identity Generator")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.top, 12)

                Text("Version 1.0")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.white.opacity(0.40))
                    .padding(.top, 2)

                Divider()
                    .overlay(Color.white.opacity(0.10))
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                VStack(spacing: 6) {
                    infoRow(label: "Developer", value: "Yuvraj Sharma")
                    infoRow(label: "Email Service", value: "mail.tm")
                    infoRow(label: "Platform", value: "macOS 13+")
                }
                .padding(.top, 16)
                .padding(.horizontal, 28)

                Divider()
                    .overlay(Color.white.opacity(0.10))
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                Text("Generates disposable Indian identities\nwith real temporary email inboxes.")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.white.opacity(0.40))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.top, 12)
                    .padding(.horizontal, 24)

                Button(action: onClose) {
                    Text("Close")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.80))
                        .padding(.horizontal, 28)
                        .padding(.vertical, 7)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                                )
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 18)
                .padding(.bottom, 24)
            }
            .frame(width: 280)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(red: 0.08, green: 0.04, blue: 0.22).opacity(0.80))
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.12), lineWidth: 0.6)
                }
            )
            .shadow(color: .black.opacity(0.5), radius: 24, y: 8)
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.40))
                .frame(width: 90, alignment: .leading)
            Text(value)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.80))
            Spacer()
        }
    }
}

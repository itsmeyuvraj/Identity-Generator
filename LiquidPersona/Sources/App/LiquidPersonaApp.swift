import SwiftUI

@main
struct LiquidPersonaApp: App {

    @StateObject private var viewModel = PersonaViewModel()

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(viewModel)
        } label: {
            // Menu bar icon — SF Symbol with a badge
            Label("Identity Generator", systemImage: "person.badge.key.fill")
                .labelStyle(.iconOnly)
        }
        .menuBarExtraStyle(.window)
    }
}

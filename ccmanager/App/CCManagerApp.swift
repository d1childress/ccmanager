import SwiftUI
import SwiftUIX

@main
struct CCManagerApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var githubService = GitHubService()
    @StateObject private var claudeService = ClaudeService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(githubService)
                .environmentObject(claudeService)
                .frame(minWidth: 1200, minHeight: 800)
                .background(VisualEffectBlur(material: .dark, blendingMode: .behindWindow))
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Connect Repository") {
                    appState.showAddRepository = true
                }
                .keyboardShortcut("r", modifiers: [.command])
            }
        }
        
        Settings {
            SettingsView()
                .environmentObject(appState)
        }
    }
}
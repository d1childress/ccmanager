import SwiftUI
import SwiftUIX

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var githubService: GitHubService
    @EnvironmentObject var claudeService: ClaudeService
    
    var body: some View {
        NavigationSplitView {
            SidebarView()
                .navigationSplitViewColumnWidth(min: 250, ideal: 300, max: 400)
        } content: {
            if let selectedRepo = appState.selectedRepository {
                RepositoryDetailView(repository: selectedRepo)
            } else {
                EmptyStateView()
            }
        } detail: {
            if appState.selectedFile != nil {
                LiveChangesView()
            } else if appState.showUsageGraph {
                UsageGraphView()
            } else {
                AgentCommandView()
            }
        }
        .navigationSplitViewStyle(.balanced)
        .background(
            LinearGradient(
                colors: [
                    Color.black.opacity(0.95),
                    Color.black.opacity(0.85)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .sheet(isPresented: $appState.showAddRepository) {
            AddRepositoryView()
        }
    }
}
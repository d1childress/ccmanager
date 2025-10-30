import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationSplitView {
            SidebarView()
                .navigationSplitViewColumnWidth(min: 240, ideal: 300, max: 380)
        } content: {
            Group {
                if let selectedRepo = appState.selectedRepository {
                    RepositoryDetailView(repository: selectedRepo)
                } else {
                    EmptyStateView()
                }
            }
            .padding(.vertical, 0)
        } detail: {
            Group {
                if appState.selectedFile != nil {
                    LiveChangesView()
                } else if appState.showUsageGraph {
                    UsageGraphView()
                } else {
                    AgentCommandView()
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: $appState.showAddRepository) {
            AddRepositoryView()
        }
    }
}
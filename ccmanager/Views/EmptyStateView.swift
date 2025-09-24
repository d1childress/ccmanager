import SwiftUI
import AppKit

struct EmptyStateView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 72))
                .foregroundColor(.white.opacity(0.2))
            
            VStack(spacing: 12) {
                Text("No Repository Selected")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                
                Text("Select a repository from the sidebar to view details and start working with Claude")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 400)
            }
            
            HStack(spacing: 16) {
                GlassButton("Add Repository") {
                    appState.showAddRepository = true
                }
                
                GlassButton("View Documentation") {
                    if let url = URL(string: "https://github.com") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color.black.opacity(0.95),
                    Color.black.opacity(0.9)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}
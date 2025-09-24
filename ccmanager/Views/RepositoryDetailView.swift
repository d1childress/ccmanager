import SwiftUI
import SwiftUIX
import AppKit

struct RepositoryDetailView: View {
    let repository: Repository
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var githubService: GitHubService
    @State private var isCloning = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                statsSection
                actionsSection
                detailsSection
            }
            .padding(20)
        }
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
        .alert("Delete Repository", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                appState.removeRepository(repository)
            }
        } message: {
            Text("Are you sure you want to remove this repository from CC Manager? This will not delete the repository from GitHub.")
        }
    }
    
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: repository.isPrivate ? "lock.fill" : "book.closed.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.8))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(repository.name)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(repository.owner)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                if let language = repository.language {
                    Text(language)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(languageColor(for: language))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(languageColor(for: language).opacity(0.2))
                        )
                }
            }
            
            if let description = repository.description {
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(3)
            }
        }
        .padding()
        .glassCard()
    }
    
    var statsSection: some View {
        HStack(spacing: 16) {
            StatItem(icon: "star.fill", value: "\(repository.stargazersCount)", label: "Stars")
            StatItem(icon: "tuningfork", value: "\(repository.forksCount)", label: "Forks")
            StatItem(icon: "exclamationmark.circle", value: "\(repository.openIssuesCount)", label: "Issues")
            StatItem(icon: "clock", value: timeAgo(from: repository.updatedAt), label: "Updated")
        }
        .padding()
        .glassCard()
    }
    
    var actionsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                GlassButton("Start Agent Session") {
                    appState.startSession(for: repository)
                    appState.showUsageGraph = false
                }
                
                if repository.localPath == nil {
                    GlassButton("Clone Locally") {
                        cloneRepository()
                    }
                } else {
                    GlassButton("Open in Finder") {
                        openInFinder()
                    }
                }
                
                GlassButton("View on GitHub") {
                    openInBrowser()
                }
            }
            
            HStack(spacing: 12) {
                GlassButton("Pull Latest") {
                    pullLatest()
                }
                
                GlassButton("View Branches") {
                    // Show branches
                }
                
                GlassButton("Remove", isDestructive: true) {
                    showingDeleteAlert = true
                }
            }
        }
        .padding()
        .glassCard()
    }
    
    var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Repository Details")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            VStack(spacing: 12) {
                DetailRow(label: "Full Name", value: repository.fullName)
                DetailRow(label: "Default Branch", value: repository.defaultBranch)
                DetailRow(label: "Visibility", value: repository.isPrivate ? "Private" : "Public")
                DetailRow(label: "Created", value: formatDate(repository.createdAt))
                if let localPath = repository.localPath {
                    DetailRow(label: "Local Path", value: localPath)
                }
            }
        }
        .padding()
        .glassCard()
    }
    
    func cloneRepository() {
        isCloning = true
        Task {
            do {
                let localPath = NSString(string: appState.settings.defaultLocalPath).expandingTildeInPath + "/\(repository.name)"
                try await githubService.cloneRepository(repository, to: localPath)
                // Update repository with local path in app state
                await MainActor.run {
                    if let index = appState.repositories.firstIndex(where: { $0.id == repository.id }) {
                        appState.repositories[index].localPath = localPath
                        appState.selectedRepository = appState.repositories[index]
                    }
                }
                isCloning = false
            } catch {
                appState.error = error.localizedDescription
                isCloning = false
            }
        }
    }
    
    func openInFinder() {
        if let localPath = repository.localPath {
            let path = NSString(string: localPath).expandingTildeInPath
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: path)
        }
    }
    
    func openInBrowser() {
        if let url = URL(string: repository.url) {
            NSWorkspace.shared.open(url)
        }
    }
    
    func pullLatest() {
        Task {
            do {
                try await githubService.pullLatest(for: repository)
            } catch {
                await MainActor.run {
                    appState.error = error.localizedDescription
                }
            }
        }
    }
    
    func languageColor(for language: String) -> Color {
        switch language.lowercased() {
        case "swift": return .orange
        case "javascript": return .yellow
        case "typescript": return .blue
        case "python": return .green
        case "ruby": return .red
        case "go": return .cyan
        case "rust": return .orange
        default: return .white.opacity(0.7)
        }
    }
    
    func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 3600 {
            return "\(Int(interval / 60))m"
        } else if interval < 86400 {
            return "\(Int(interval / 3600))h"
        } else if interval < 604800 {
            return "\(Int(interval / 86400))d"
        } else {
            return "\(Int(interval / 604800))w"
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white.opacity(0.6))
            
            Text(value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}
import SwiftUI
import SwiftUIX

struct SidebarView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var githubService: GitHubService
    @State private var searchText = ""
    
    var filteredRepositories: [Repository] {
        if searchText.isEmpty {
            return appState.repositories
        } else {
            return appState.repositories.filter { repo in
                repo.name.localizedCaseInsensitiveContains(searchText) ||
                repo.owner.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            searchBar
            repositoryList
            bottomBar
        }
        .background(Color.black.opacity(0.4))
    }
    
    var headerView: some View {
        HStack {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 24))
                .foregroundColor(.purple)
            
            Text("CC Manager")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: { appState.showAddRepository = true }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.8))
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color.black.opacity(0.3))
    }
    
    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.5))
            
            TextField("Search repositories...", text: $searchText)
                .textFieldStyle(.plain)
                .foregroundColor(.white)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.05))
        )
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    var repositoryList: some View {
        ScrollView {
            LazyVStack(spacing: 4) {
                ForEach(filteredRepositories) { repo in
                    RepositoryRow(repository: repo)
                        .onTapGesture {
                            appState.selectedRepository = repo
                        }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
    }
    
    var bottomBar: some View {
        VStack(spacing: 12) {
            Divider()
                .background(Color.white.opacity(0.1))
            
            HStack(spacing: 16) {
                bottomButton(icon: "chart.line.uptrend.xyaxis", label: "Usage") {
                    appState.showUsageGraph = true
                }
                
                bottomButton(icon: "gear", label: "Settings") {
                    appState.showSettings = true
                }
                
                bottomButton(icon: "questionmark.circle", label: "Help") {
                    appState.showHelp = true
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .background(Color.black.opacity(0.3))
    }
    
    func bottomButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(.white.opacity(0.7))
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

struct RepositoryRow: View {
    let repository: Repository
    @EnvironmentObject var appState: AppState
    
    var isSelected: Bool {
        appState.selectedRepository?.id == repository.id
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: repository.isPrivate ? "lock.fill" : "book.closed.fill")
                .font(.system(size: 16))
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(repository.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.9))
                
                Text(repository.owner)
                    .font(.system(size: 11))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .white.opacity(0.5))
            }
            
            Spacer()
            
            if let language = repository.language {
                Text(language)
                    .font(.system(size: 10))
                    .foregroundColor(languageColor(for: language))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(languageColor(for: language).opacity(0.2))
                    )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.white.opacity(0.1) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.purple.opacity(0.5) : Color.clear, lineWidth: 1)
        )
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
}
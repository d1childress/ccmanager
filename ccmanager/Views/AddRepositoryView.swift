import SwiftUI

struct AddRepositoryView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var githubService: GitHubService
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText = ""
    @State private var selectedTab = "Search"
    @State private var githubToken = ""
    @State private var isAuthenticating = false
    
    let tabs = ["Search", "URL", "Local"]
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            
            Picker("Method", selection: $selectedTab) {
                ForEach(tabs, id: \.self) { tab in
                    Text(tab).tag(tab)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            switch selectedTab {
            case "Search":
                searchView
            case "URL":
                urlView
            case "Local":
                localView
            default:
                EmptyView()
            }
            
            Spacer()
            
            bottomButtons
        }
        .frame(width: 600, height: 500)
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
    
    var headerSection: some View {
        HStack {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.purple)
            
            Text("Add Repository")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color.black.opacity(0.5))
    }
    
    var searchView: some View {
        VStack(spacing: 20) {
            if !githubService.isAuthenticated {
                VStack(spacing: 16) {
                    Text("GitHub Authentication Required")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("Enter your GitHub personal access token to search and import repositories")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                    
                    GlassTextField(placeholder: "GitHub Token", text: $githubToken)
                    
                    GlassButton("Authenticate") {
                        authenticateGitHub()
                    }
                }
                .padding()
                .glassCard()
                .padding()
            } else {
                VStack(spacing: 16) {
                    GlassTextField(placeholder: "Search repositories...", text: $searchText)
                    
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(githubService.repositories.filter { repo in
                                searchText.isEmpty || repo.name.localizedCaseInsensitiveContains(searchText)
                            }) { repo in
                                RepoSearchRow(repository: repo) {
                                    appState.addRepository(repo)
                                    dismiss()
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 300)
                }
                .padding()
            }
        }
    }
    
    var urlView: some View {
        VStack(spacing: 20) {
            Text("Add Repository by URL")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            Text("Enter a GitHub repository URL to add it to CC Manager")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
            
            GlassTextField(placeholder: "https://github.com/user/repo", text: $searchText)
            
            GlassButton("Add Repository") {
                // Parse URL and add repository
                dismiss()
            }
        }
        .padding()
        .glassCard()
        .padding()
    }
    
    var localView: some View {
        VStack(spacing: 20) {
            Text("Add Local Repository")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            Text("Select a local Git repository to add to CC Manager")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
            
            GlassButton("Choose Directory") {
                chooseDirectory()
            }
            
            if !searchText.isEmpty {
                HStack {
                    Image(systemName: "folder.fill")
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text(searchText)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.05))
                )
            }
        }
        .padding()
        .glassCard()
        .padding()
    }
    
    var bottomButtons: some View {
        HStack {
            Spacer()
            
            GlassButton("Cancel") {
                dismiss()
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
    }
    
    func authenticateGitHub() {
        isAuthenticating = true
        githubService.authenticate(with: githubToken)
        isAuthenticating = false
    }
    
    func chooseDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK, let url = panel.url {
            searchText = url.path
        }
    }
}

struct RepoSearchRow: View {
    let repository: Repository
    let onSelect: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: repository.isPrivate ? "lock.fill" : "book.closed.fill")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(repository.name)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.9))
                
                Text(repository.owner)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            if let language = repository.language {
                Text(language)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Button(action: onSelect) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.green)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.03))
        )
    }
}
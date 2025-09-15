import Foundation
import SwiftUI
import Combine

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var repositories: [Repository] = []
    @Published var selectedRepository: Repository?
    @Published var selectedFile: FileChange?
    @Published var currentSession: AgentSession?
    @Published var sessions: [AgentSession] = []
    @Published var usageHistory: [UsageData] = []
    @Published var error: String?
    @Published var isLoading = false
    
    // UI State
    @Published var showAddRepository = false
    @Published var showSettings = false
    @Published var showUsageGraph = false
    @Published var showHelp = false
    
    // Settings
    @Published var settings = AppSettings()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSettings()
        loadMockRepositories()
    }
    
    func startSession(for repository: Repository) {
        let session = AgentSession(repository: repository)
        sessions.append(session)
        currentSession = session
    }
    
    func endCurrentSession() {
        currentSession?.endTime = Date()
        currentSession?.isActive = false
        currentSession = nil
    }
    
    func addRepository(_ repository: Repository) {
        repositories.append(repository)
        saveRepositories()
    }
    
    func removeRepository(_ repository: Repository) {
        repositories.removeAll { $0.id == repository.id }
        if selectedRepository?.id == repository.id {
            selectedRepository = nil
        }
        saveRepositories()
    }
    
    func updateUsageData() {
        let today = UsageData(
            date: Date(),
            claudeTokens: Int.random(in: 1000...10000),
            codexTokens: Int.random(in: 500...5000),
            apiCalls: Int.random(in: 10...100),
            cost: Double.random(in: 0.5...10.0)
        )
        usageHistory.append(today)
    }
    
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "AppSettings"),
           let settings = try? JSONDecoder().decode(AppSettings.self, from: data) {
            self.settings = settings
        }
    }
    
    func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: "AppSettings")
        }
    }
    
    private func loadRepositories() {
        if let data = UserDefaults.standard.data(forKey: "Repositories"),
           let repos = try? JSONDecoder().decode([Repository].self, from: data) {
            self.repositories = repos
        }
    }
    
    private func saveRepositories() {
        if let data = try? JSONEncoder().encode(repositories) {
            UserDefaults.standard.set(data, forKey: "Repositories")
        }
    }
    
    private func loadMockRepositories() {
        repositories = [
            Repository(
                id: "1",
                name: "SwiftUI-Examples",
                fullName: "user/SwiftUI-Examples",
                owner: "user",
                description: "Collection of SwiftUI examples and best practices",
                url: "https://github.com/user/SwiftUI-Examples",
                defaultBranch: "main",
                isPrivate: false,
                language: "Swift",
                stargazersCount: 245,
                forksCount: 42,
                openIssuesCount: 3,
                createdAt: Date().addingTimeInterval(-10000000),
                updatedAt: Date().addingTimeInterval(-86400),
                localPath: "~/Developer/SwiftUI-Examples"
            ),
            Repository(
                id: "2",
                name: "react-dashboard",
                fullName: "user/react-dashboard",
                owner: "user",
                description: "Modern React dashboard with TypeScript",
                url: "https://github.com/user/react-dashboard",
                defaultBranch: "main",
                isPrivate: true,
                language: "TypeScript",
                stargazersCount: 128,
                forksCount: 23,
                openIssuesCount: 7,
                createdAt: Date().addingTimeInterval(-5000000),
                updatedAt: Date().addingTimeInterval(-172800),
                localPath: "~/Developer/react-dashboard"
            ),
            Repository(
                id: "3",
                name: "python-ml-toolkit",
                fullName: "user/python-ml-toolkit",
                owner: "user",
                description: "Machine learning toolkit for Python",
                url: "https://github.com/user/python-ml-toolkit",
                defaultBranch: "main",
                isPrivate: false,
                language: "Python",
                stargazersCount: 567,
                forksCount: 89,
                openIssuesCount: 12,
                createdAt: Date().addingTimeInterval(-20000000),
                updatedAt: Date().addingTimeInterval(-259200),
                localPath: nil
            )
        ]
    }
}
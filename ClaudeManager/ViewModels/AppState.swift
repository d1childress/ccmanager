import Foundation
import SwiftUI
import Combine

class AppState: ObservableObject {
    static let shared = AppState()

    // Data
    @Published var repositories: [Repository] = []
    @Published var selectedRepository: Repository?
    @Published var selectedFile: FileChange?

    // Sessions
    @Published var currentSession: AgentSession?
    @Published var sessions: [AgentSession] = []

    // UI State
    @Published var showAddRepository = false
    @Published var showSettings = false
    @Published var showUsageGraph = false
    @Published var showHelp = false

    // Settings
    @Published var settings = AppSettings()

    // Status
    @Published var error: String?
    @Published var isLoading = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        loadSettings()
        loadRepositories()
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
}
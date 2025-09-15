import Foundation
import SwiftUI

struct Repository: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let fullName: String
    let owner: String
    let description: String?
    let url: String
    let defaultBranch: String
    let isPrivate: Bool
    let language: String?
    let stargazersCount: Int
    let forksCount: Int
    let openIssuesCount: Int
    let createdAt: Date
    let updatedAt: Date
    let localPath: String?
    
    static func == (lhs: Repository, rhs: Repository) -> Bool {
        lhs.id == rhs.id
    }
}

struct FileChange: Identifiable {
    let id = UUID()
    let filePath: String
    let changeType: ChangeType
    let additions: Int
    let deletions: Int
    let patch: String?
    let timestamp: Date
    
    enum ChangeType: String, CaseIterable {
        case added = "Added"
        case modified = "Modified"
        case deleted = "Deleted"
        case renamed = "Renamed"
    }
}

struct AgentCommand: Identifiable {
    let id = UUID()
    let command: String
    let timestamp: Date
    let status: CommandStatus
    let output: String?
    let error: String?
    
    enum CommandStatus {
        case pending
        case running
        case completed
        case failed
    }
}

struct UsageData: Identifiable {
    let id = UUID()
    let date: Date
    let claudeTokens: Int
    let codexTokens: Int
    let apiCalls: Int
    let cost: Double
}

struct AgentSession: Identifiable {
    let id = UUID()
    var repository: Repository
    var commands: [AgentCommand] = []
    var changes: [FileChange] = []
    var startTime: Date = Date()
    var endTime: Date?
    var isActive: Bool = true
}

struct GitHubCredentials: Codable {
    let accessToken: String
    let username: String
}

struct ClaudeCredentials: Codable {
    let apiKey: String
    let organizationId: String?
}

struct AppSettings: Codable {
    var githubCredentials: GitHubCredentials?
    var claudeCredentials: ClaudeCredentials?
    var defaultLocalPath: String = "~/Developer"
    var autoSync: Bool = true
    var syncInterval: TimeInterval = 300
    var showNotifications: Bool = true
    var theme: AppTheme = .dark
}

enum AppTheme: String, Codable, CaseIterable {
    case dark = "Dark"
    case light = "Light"
    case auto = "Auto"
}
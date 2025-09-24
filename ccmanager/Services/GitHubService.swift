import Foundation
import Combine
import SwiftUI

class GitHubService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var repositories: [Repository] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let baseURL = "https://api.github.com"
    private var accessToken: String?
    private let iso8601Formatter = ISO8601DateFormatter()
    
    func authenticate(with token: String) {
        self.accessToken = token
        self.isAuthenticated = true
        fetchRepositories()
    }
    
    func fetchRepositories() {
        guard let token = accessToken else {
            error = "Not authenticated"
            return
        }
        
        isLoading = true
        error = nil
        
        var request = URLRequest(url: URL(string: "\(baseURL)/user/repos?per_page=100")!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [GitHubRepository].self, decoder: JSONDecoder())
            .map { repos in
                repos.map { repo in
                    Repository(
                        id: String(repo.id),
                        name: repo.name,
                        fullName: repo.full_name,
                        owner: repo.owner.login,
                        description: repo.description,
                        url: repo.html_url,
                        defaultBranch: repo.default_branch ?? "main",
                        isPrivate: repo.private,
                        language: repo.language,
                        stargazersCount: repo.stargazers_count,
                        forksCount: repo.forks_count,
                        openIssuesCount: repo.open_issues_count,
                        createdAt: iso8601Formatter.date(from: repo.created_at) ?? Date(),
                        updatedAt: iso8601Formatter.date(from: repo.updated_at) ?? Date(),
                        localPath: nil
                    )
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoading = false
                    if case .failure(let error) = completion {
                        self.error = error.localizedDescription
                    }
                },
                receiveValue: { repositories in
                    self.repositories = repositories
                }
            )
            .store(in: &cancellables)
    }
    
    func cloneRepository(_ repository: Repository, to localPath: String) async throws {
        let expandedPath = expandTilde(in: localPath)
        // Prefer HTTPS clone URL computed from fullName to avoid using the HTML URL
        let cloneURL = "https://github.com/\(repository.fullName).git"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["clone", cloneURL, expandedPath]
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            throw GitError.cloneFailed
        }
    }
    
    func fetchChanges(for repository: Repository) async throws -> [FileChange] {
        guard let localPath = repository.localPath else {
            throw GitError.noLocalPath
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.currentDirectoryURL = URL(fileURLWithPath: expandTilde(in: localPath))
        process.arguments = ["diff", "--name-status", "HEAD"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        return parseGitDiff(output)
    }
    
    func pullLatest(for repository: Repository) async throws {
        guard let localPath = repository.localPath else {
            throw GitError.noLocalPath
        }
        let expanded = expandTilde(in: localPath)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.currentDirectoryURL = URL(fileURLWithPath: expanded)
        process.arguments = ["pull", "--ff-only"]
        try process.run()
        process.waitUntilExit()
        if process.terminationStatus != 0 {
            throw GitError.commandFailed
        }
    }
    
    private func parseGitDiff(_ diff: String) -> [FileChange] {
        let lines = diff.split(separator: "\n")
        var changes: [FileChange] = []
        
        for line in lines {
            let parts = line.split(separator: "\t")
            guard parts.count >= 2 else { continue }
            
            let status = String(parts[0])
            let filePath = String(parts[1])
            
            let changeType: FileChange.ChangeType
            switch status {
            case "A": changeType = .added
            case "M": changeType = .modified
            case "D": changeType = .deleted
            case "R": changeType = .renamed
            default: continue
            }
            
            changes.append(FileChange(
                filePath: filePath,
                changeType: changeType,
                additions: 0,
                deletions: 0,
                patch: nil,
                timestamp: Date()
            ))
        }
        
        return changes
    }
    
    enum GitError: LocalizedError {
        case cloneFailed
        case noLocalPath
        case commandFailed
        
        var errorDescription: String? {
            switch self {
            case .cloneFailed:
                return "Failed to clone repository"
            case .noLocalPath:
                return "Repository has no local path"
            case .commandFailed:
                return "Git command failed"
            }
        }
    }
    
    private func expandTilde(in path: String) -> String {
        NSString(string: path).expandingTildeInPath
    }
}

private struct GitHubRepository: Codable {
    let id: Int
    let name: String
    let full_name: String
    let owner: GitHubOwner
    let description: String?
    let html_url: String
    let default_branch: String?
    let `private`: Bool
    let language: String?
    let stargazers_count: Int
    let forks_count: Int
    let open_issues_count: Int
    let created_at: String
    let updated_at: String
}

private struct GitHubOwner: Codable {
    let login: String
}
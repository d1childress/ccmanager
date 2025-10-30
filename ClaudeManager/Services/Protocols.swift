import Foundation
import Combine

public protocol LLMService: AnyObject, ObservableObject {
    var isConnected: Bool { get }
    var isProcessing: Bool { get }
    var currentResponse: String? { get }
    var error: String? { get }
    func connect(apiKey: String)
    func executeCommand(_ command: String, context: LLMContext?) async throws
    func streamCommand(_ command: String, context: LLMContext?) -> AsyncStream<String>
    func estimateTokens(for text: String) -> Int
    func estimateCost(tokens: Int) -> Double
}

public struct LLMContext {
    public let repositoryName: String?
    public let language: String?
    public init(repositoryName: String? = nil, language: String? = nil) {
        self.repositoryName = repositoryName
        self.language = language
    }
}

public protocol VCSService: AnyObject, ObservableObject {
    var isAuthenticated: Bool { get }
    var repositories: [Repository] { get }
    var isLoading: Bool { get }
    var error: String? { get }
    func authenticate(with token: String)
    func fetchRepositories()
    func cloneRepository(_ repository: Repository, to localPath: String) async throws
    func fetchChanges(for repository: Repository) async throws -> [FileChange]
}


import Foundation
import Combine
import SwiftUI

class ClaudeService: ObservableObject {
    @Published var isConnected = false
    @Published var isProcessing = false
    @Published var currentResponse: String?
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let baseURL = "https://api.anthropic.com/v1"
    private var apiKey: String?
    
    // Reference to app state is injected from the App entry to avoid using a global singleton
    var appState: AppState?
    
    func connect(apiKey: String) {
        self.apiKey = apiKey
        self.isConnected = true
    }
    
    func executeCommand(_ command: String, for repository: Repository?) async throws {
        guard let apiKey = apiKey else {
            throw ClaudeError.notAuthenticated
        }
        
        isProcessing = true
        defer { isProcessing = false }
        
        var request = URLRequest(url: URL(string: "\(baseURL)/messages")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        
        let context: String
        if let repo = repository {
            let repoLanguage = repo.language ?? "Unknown"
            context = "Repository: \(repo.name)\nLanguage: \(repoLanguage)\n\n"
        } else {
            context = ""
        }
        
        let body: [String: Any] = [
            "model": "claude-3-opus-20240229",
            "max_tokens": 4096,
            "messages": [
                [
                    "role": "user",
                    "content": "\(context)Command: \(command)"
                ]
            ],
            "system": "You are a code assistant helping with repository management and code generation. Provide clear, concise responses with code examples when appropriate."
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClaudeError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            let responseData = try JSONDecoder().decode(ClaudeResponse.self, from: data)
            await MainActor.run {
                self.currentResponse = responseData.content.first?.text
                
                if self.appState?.currentSession != nil {
                    let commandEntry = AgentCommand(
                        command: command,
                        timestamp: Date(),
                        status: .completed,
                        output: self.currentResponse,
                        error: nil
                    )
                    self.appState?.appendCommandToCurrentSession(commandEntry)
                }
            }
        } else {
            throw ClaudeError.apiError(statusCode: httpResponse.statusCode)
        }
    }
    
    func streamCommand(_ command: String, for repository: Repository?) -> AsyncStream<String> {
        AsyncStream { continuation in
            Task {
                guard let apiKey = apiKey else {
                    continuation.finish()
                    return
                }
                
                var request = URLRequest(url: URL(string: "\(baseURL)/messages")!)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
                request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
                
                let context: String = repository.map { "Repository: \($0.name)\n" } ?? ""
                
                let body: [String: Any] = [
                    "model": "claude-3-opus-20240229",
                    "max_tokens": 4096,
                    "stream": true,
                    "messages": [
                        [
                            "role": "user",
                            "content": "\(context)Command: \(command)"
                        ]
                    ]
                ]
                
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)
                    
                    let (bytes, _) = try await URLSession.shared.bytes(for: request)
                    
                    for try await line in bytes.lines {
                        if line.hasPrefix("data: ") {
                            let jsonString = String(line.dropFirst(6))
                            if jsonString == "[DONE]" {
                                continuation.finish()
                                break
                            }
                            
                            if let data = jsonString.data(using: .utf8),
                               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                               let delta = json["delta"] as? [String: Any],
                               let text = delta["text"] as? String {
                                continuation.yield(text)
                            }
                        }
                    }
                } catch {
                    continuation.finish()
                }
            }
        }
    }
    
    func estimateTokens(for text: String) -> Int {
        // Rough estimation: ~4 characters per token
        return text.count / 4
    }
    
    func estimateCost(tokens: Int, model: ClaudeModel = .opus) -> Double {
        switch model {
        case .opus:
            return Double(tokens) * 0.00003
        case .sonnet:
            return Double(tokens) * 0.00001
        case .haiku:
            return Double(tokens) * 0.0000025
        }
    }
    
    enum ClaudeError: LocalizedError {
        case notAuthenticated
        case invalidResponse
        case apiError(statusCode: Int)
        
        var errorDescription: String? {
            switch self {
            case .notAuthenticated:
                return "Claude API key not configured"
            case .invalidResponse:
                return "Invalid response from Claude API"
            case .apiError(let statusCode):
                return "API error: HTTP \(statusCode)"
            }
        }
    }
    
    enum ClaudeModel {
        case opus
        case sonnet
        case haiku
    }
}

private struct ClaudeResponse: Codable {
    let id: String
    let type: String
    let role: String
    let content: [Content]
    let model: String
    let usage: Usage?
    
    struct Content: Codable {
        let type: String
        let text: String
    }
    
    struct Usage: Codable {
        let input_tokens: Int
        let output_tokens: Int
    }
}
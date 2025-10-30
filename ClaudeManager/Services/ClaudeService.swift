import Foundation
import Combine
import SwiftUI

class ClaudeService: LLMService {
    @Published var isConnected = false
    @Published var isProcessing = false
    @Published var currentResponse: String?
    @Published var error: String?

    private var cancellables = Set<AnyCancellable>()
    private let baseURL = "https://api.anthropic.com/v1"
    private var apiKey: String?

    func connect(apiKey: String) {
        self.apiKey = apiKey
        self.isConnected = true
    }

    func executeCommand(_ command: String, context: LLMContext?) async throws {
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

        let prefix: String
        if let context = context {
            let repoName = context.repositoryName ?? "Unknown"
            let language = context.language ?? "Unknown"
            prefix = "Repository: \(repoName)\nLanguage: \(language)\n\n"
        } else {
            prefix = ""
        }

        let body: [String: Any] = [
            "model": "claude-3-opus-20240229",
            "max_tokens": 4096,
            "messages": [
                [
                    "role": "user",
                    "content": "\(prefix)Command: \(command)"
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

                if AppState.shared.currentSession != nil {
                    let cmd = AgentCommand(
                        command: command,
                        timestamp: Date(),
                        status: .completed,
                        output: self.currentResponse,
                        error: nil
                    )
                    AppState.shared.currentSession?.commands.append(cmd)
                }
            }
        } else {
            throw ClaudeError.apiError(statusCode: httpResponse.statusCode)
        }
    }

    func streamCommand(_ command: String, context: LLMContext?) -> AsyncStream<String> {
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
                
                let prefix: String
                if let context = context {
                    let repoName = context.repositoryName ?? "Unknown"
                    prefix = "Repository: \(repoName)\n"
                } else {
                    prefix = ""
                }
                
                let body: [String: Any] = [
                    "model": "claude-3-opus-20240229",
                    "max_tokens": 4096,
                    "stream": true,
                    "messages": [
                        [
                            "role": "user",
                            "content": "\(prefix)Command: \(command)"
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
    
    func estimateCost(tokens: Int) -> Double {
        Double(tokens) * 0.00003
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
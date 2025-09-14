import SwiftUI
import Foundation
import AuthenticationServices
import WebKit

struct ContentView: View {
    @StateObject private var authManager = AuthenticationManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)
                .environmentObject(authManager)
            
            LoginView()
                .tabItem { Label("Login", systemImage: "person.circle.fill") }
                .tag(1)
                .environmentObject(authManager)
            
            if authManager.isClaudeAuthenticated {
                ClaudeView()
                    .tabItem { Label("Claude", systemImage: "brain.head.profile") }
                    .tag(2)
                    .environmentObject(authManager)
            }
            
            if authManager.isChatGPTAuthenticated {
                ChatGPTView()
                    .tabItem { Label("ChatGPT", systemImage: "message.circle.fill") }
                    .tag(3)
                    .environmentObject(authManager)
            }
            
            if authManager.isGitHubAuthenticated {
                GitHubView()
                    .tabItem { Label("GitHub", systemImage: "arrow.triangle.branch") }
                    .tag(4)
                    .environmentObject(authManager)
            }
            
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(5)
                .environmentObject(authManager)
        }
        .frame(minWidth: 1400, minHeight: 900)
        .preferredColorScheme(.dark)
        .onChange(of: authManager.isClaudeAuthenticated) { oldValue, newValue in
            if selectedTab == 1 && newValue {
                selectedTab = 2 // Switch to Claude tab after login
            }
        }
        .onChange(of: authManager.isChatGPTAuthenticated) { oldValue, newValue in
            if selectedTab == 1 && newValue {
                selectedTab = 3 // Switch to ChatGPT tab after login
            }
        }
    }
}

// MARK: - Home View
struct HomeView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var isAnimating = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // Hero Section
                VStack(spacing: 24) {
                    HStack(spacing: 16) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 48))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 2).repeatForever(), value: isAnimating)
                        
                        Image(systemName: "message.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 2).repeatForever().delay(0.5), value: isAnimating)
                        
                        Image(systemName: "arrow.triangle.branch")
                            .font(.system(size: 48))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 2).repeatForever().delay(1.0), value: isAnimating)
                    }
                    
                    VStack(spacing: 12) {
                        Text("AI Code Assistant")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .gray],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        Text("Claude • ChatGPT • GitHub Integration")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("The ultimate coding companion that combines the power of Claude AI, ChatGPT, and GitHub in one beautiful macOS app")
                        .font(.title3)
                        .fontWeight(.light)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary.opacity(0.8))
                        .padding(.horizontal, 60)
                }
                .padding(.top, 60)
                
                // Quick Start Section
                VStack(spacing: 24) {
                    Text("Quick Start")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3), spacing: 20) {
                        QuickStartCard(
                            icon: "1.circle.fill",
                            title: "Login",
                            description: "Connect your Claude and ChatGPT accounts",
                            color: .blue,
                            isCompleted: authManager.isClaudeAuthenticated || authManager.isChatGPTAuthenticated
                        )
                        
                        QuickStartCard(
                            icon: "2.circle.fill",
                            title: "Connect GitHub",
                            description: "Access your repositories",
                            color: .purple,
                            isCompleted: authManager.isGitHubAuthenticated
                        )
                        
                        QuickStartCard(
                            icon: "3.circle.fill",
                            title: "Start Coding",
                            description: "Get AI assistance with your projects",
                            color: .green,
                            isCompleted: authManager.isClaudeAuthenticated && authManager.isChatGPTAuthenticated
                        )
                    }
                    .padding(.horizontal, 40)
                }
                
                // Features Section
                VStack(spacing: 24) {
                    Text("Powerful Features")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                        FeatureCard(
                            icon: "brain.head.profile",
                            title: "Claude AI",
                            description: "Advanced reasoning and code analysis with Claude's latest models",
                            gradient: LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        
                        FeatureCard(
                            icon: "message.circle.fill",
                            title: "ChatGPT Integration",
                            description: "Code generation and debugging with GPT-4 and latest models",
                            gradient: LinearGradient(colors: [.green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        
                        FeatureCard(
                            icon: "arrow.triangle.branch",
                            title: "GitHub Sync",
                            description: "Seamless repository integration and context-aware assistance",
                            gradient: LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        
                        FeatureCard(
                            icon: "lock.shield.fill",
                            title: "Secure & Private",
                            description: "OAuth authentication and encrypted credential storage",
                            gradient: LinearGradient(colors: [.indigo, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                    }
                    .padding(.horizontal, 40)
                }
                
                // Status Dashboard
                StatusDashboard()
                    .environmentObject(authManager)
                
                Spacer()
            }
        }
        .background(
            LinearGradient(
                colors: [
                    Color(NSColor.windowBackgroundColor),
                    Color(NSColor.controlBackgroundColor).opacity(0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onAppear {
            isAnimating = true
        }
    }
}

struct QuickStartCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let isCompleted: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: isCompleted ? "checkmark.circle.fill" : icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(isCompleted ? .green : color)
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isCompleted ? Color.green.opacity(0.5) : Color.clear, lineWidth: 2)
        )
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let gradient: LinearGradient
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(gradient)
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(16)
    }
}

struct StatusDashboard: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Connection Status")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                StatusIndicatorCard(
                    title: "Claude",
                    isConnected: authManager.isClaudeAuthenticated,
                    icon: "brain.head.profile",
                    color: .orange
                )
                
                StatusIndicatorCard(
                    title: "ChatGPT",
                    isConnected: authManager.isChatGPTAuthenticated,
                    icon: "message.circle.fill",
                    color: .green
                )
                
                StatusIndicatorCard(
                    title: "GitHub",
                    isConnected: authManager.isGitHubAuthenticated,
                    icon: "arrow.triangle.branch",
                    color: .purple
                )
            }
        }
        .padding(24)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
        .cornerRadius(20)
        .padding(.horizontal, 40)
    }
}

struct StatusIndicatorCard: View {
    let title: String
    let isConnected: Bool
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isConnected ? color.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isConnected ? color : .gray)
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(isConnected ? "Connected" : "Not Connected")
                    .font(.caption)
                    .foregroundColor(isConnected ? color : .secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(12)
    }
}

// MARK: - Authentication Manager (Simplified for space)
class AuthenticationManager: ObservableObject {
    @Published var isClaudeAuthenticated = false
    @Published var isChatGPTAuthenticated = false
    @Published var isGitHubAuthenticated = false
    
    @Published var claudeUser: ClaudeUser?
    @Published var chatGPTUser: ChatGPTUser?
    @Published var githubUser: GitHubUser?
    
    @Published var isAuthenticating = false
    @Published var authError: String?
    
    private let keychain = KeychainHelper()
    
    init() {
        loadStoredCredentials()
    }
    
    func loginWithClaude() {
        isAuthenticating = true
        authError = nil
        
        // Simulate successful login
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.claudeUser = ClaudeUser(id: "1", name: "Claude User", email: "user@example.com", subscription: "Pro", avatarUrl: nil)
            self.isClaudeAuthenticated = true
            self.isAuthenticating = false
        }
    }
    
    func loginWithChatGPT() {
        isAuthenticating = true
        authError = nil
        
        // Simulate successful login
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.chatGPTUser = ChatGPTUser(id: "1", name: "OpenAI User", email: "user@openai.com", subscription: "Plus", avatarUrl: nil)
            self.isChatGPTAuthenticated = true
            self.isAuthenticating = false
        }
    }
    
    func loginWithGitHub() {
        isAuthenticating = true
        authError = nil
        
        // Simulate successful login
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.githubUser = GitHubUser(id: 12345, login: "github_user", name: "GitHub User", email: "user@github.com", avatarUrl: nil, publicRepos: 25, followers: 100)
            self.isGitHubAuthenticated = true
            self.isAuthenticating = false
        }
    }
    
    func logout(from service: String) {
        switch service {
        case "claude":
            keychain.delete(key: "claude_access_token")
            claudeUser = nil
            isClaudeAuthenticated = false
        case "chatgpt":
            keychain.delete(key: "chatgpt_access_token")
            chatGPTUser = nil
            isChatGPTAuthenticated = false
        case "github":
            keychain.delete(key: "github_access_token")
            githubUser = nil
            isGitHubAuthenticated = false
        default:
            break
        }
    }
    
    private func loadStoredCredentials() {
        // Check for stored credentials and restore if found
        if keychain.load(key: "claude_access_token") != nil {
            isClaudeAuthenticated = true
            claudeUser = ClaudeUser(id: "stored", name: "Claude User", email: "stored@example.com", subscription: "Pro", avatarUrl: nil)
        }
        
        if keychain.load(key: "chatgpt_access_token") != nil {
            isChatGPTAuthenticated = true
            chatGPTUser = ChatGPTUser(id: "stored", name: "OpenAI User", email: "stored@openai.com", subscription: "Plus", avatarUrl: nil)
        }
        
        if keychain.load(key: "github_access_token") != nil {
            isGitHubAuthenticated = true
            githubUser = GitHubUser(id: 12345, login: "stored_user", name: "GitHub User", email: "stored@github.com", avatarUrl: nil, publicRepos: 25, followers: 100)
        }
    }
}

// MARK: - Data Models
struct ClaudeUser: Identifiable {
    let id: String
    let name: String
    let email: String
    let subscription: String
    let avatarUrl: String?
}

struct ChatGPTUser: Identifiable {
    let id: String
    let name: String
    let email: String
    let subscription: String
    let avatarUrl: String?
}

struct GitHubUser: Identifiable {
    let id: Int
    let login: String
    let name: String
    let email: String?
    let avatarUrl: String?
    let publicRepos: Int
    let followers: Int
}

// MARK: - Login View
struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Sign In to Your Accounts")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Connect with your Claude, ChatGPT, and GitHub accounts")
                        .font(.title3)
                        .fontWeight(.light)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 40)
                
                // Login Cards
                VStack(spacing: 24) {
                    LoginCard(
                        title: "Claude",
                        subtitle: "Anthropic",
                        description: "Advanced reasoning and code analysis",
                        icon: "brain.head.profile",
                        gradient: LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing),
                        isAuthenticated: authManager.isClaudeAuthenticated,
                        isLoading: authManager.isAuthenticating,
                        user: authManager.claudeUser?.name
                    ) {
                        authManager.loginWithClaude()
                    } logoutAction: {
                        authManager.logout(from: "claude")
                    }
                    
                    LoginCard(
                        title: "ChatGPT",
                        subtitle: "OpenAI",
                        description: "Code generation and debugging assistance",
                        icon: "message.circle.fill",
                        gradient: LinearGradient(colors: [.green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                        isAuthenticated: authManager.isChatGPTAuthenticated,
                        isLoading: authManager.isAuthenticating,
                        user: authManager.chatGPTUser?.name
                    ) {
                        authManager.loginWithChatGPT()
                    } logoutAction: {
                        authManager.logout(from: "chatgpt")
                    }
                    
                    LoginCard(
                        title: "GitHub",
                        subtitle: "Repository Access",
                        description: "Connect your repositories for context-aware AI",
                        icon: "arrow.triangle.branch",
                        gradient: LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing),
                        isAuthenticated: authManager.isGitHubAuthenticated,
                        isLoading: authManager.isAuthenticating,
                        user: authManager.githubUser?.name
                    ) {
                        authManager.loginWithGitHub()
                    } logoutAction: {
                        authManager.logout(from: "github")
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
    }
}

struct LoginCard: View {
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let gradient: LinearGradient
    let isAuthenticated: Bool
    let isLoading: Bool
    let user: String?
    let loginAction: () -> Void
    let logoutAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(gradient.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: icon)
                        .font(.system(size: 32))
                        .foregroundStyle(gradient)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if isAuthenticated {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let user = user, isAuthenticated {
                        Text("Signed in as \(user)")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
            }
            
            // Action Button
            if isAuthenticated {
                Button("Sign Out") {
                    logoutAction()
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
            } else {
                Button(action: loginAction) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        
                        Text(isLoading ? "Signing In..." : "Sign In with \(title)")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(gradient)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isLoading)
            }
        }
        .padding(24)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isAuthenticated ? gradient.opacity(0.5) : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Service Views (Simplified)
struct ClaudeView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        VStack {
            Text("Claude AI Assistant")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            if let user = authManager.claudeUser {
                Text("Welcome, \(user.name)!")
                    .font(.headline)
                    .foregroundColor(.orange)
                    .padding()
            }
            
            Text("Claude chat interface would appear here...")
                .foregroundColor(.secondary)
                .padding()
            
            Spacer()
        }
    }
}

struct ChatGPTView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        VStack {
            Text("ChatGPT Code Generator")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            if let user = authManager.chatGPTUser {
                Text("Welcome, \(user.name)!")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding()
            }
            
            Text("ChatGPT interface would appear here...")
                .foregroundColor(.secondary)
                .padding()
            
            Spacer()
        }
    }
}

struct GitHubView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        VStack {
            Text("GitHub Repositories")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            if let user = authManager.githubUser {
                VStack(spacing: 8) {
                    Text("Welcome, \(user.name)!")
                        .font(.headline)
                        .foregroundColor(.purple)
                    
                    Text("\(user.publicRepos) repositories • \(user.followers) followers")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            
            Text("Repository list would appear here...")
                .foregroundColor(.secondary)
                .padding()
            
            Spacer()
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            VStack(spacing: 16) {
                Text("Connected Accounts")
                    .font(.headline)
                
                if authManager.isClaudeAuthenticated {
                    HStack {
                        Text("Claude: Connected")
                        Spacer()
                        Button("Disconnect") {
                            authManager.logout(from: "claude")
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                }
                
                if authManager.isChatGPTAuthenticated {
                    HStack {
                        Text("ChatGPT: Connected")
                        Spacer()
                        Button("Disconnect") {
                            authManager.logout(from: "chatgpt")
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                }
                
                if authManager.isGitHubAuthenticated {
                    HStack {
                        Text("GitHub: Connected")
                        Spacer()
                        Button("Disconnect") {
                            authManager.logout(from: "github")
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                }
            }
            .padding()
            
            Spacer()
        }
    }
}

// MARK: - Keychain Helper
class KeychainHelper {
    func save(key: String, value: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        
        if SecItemCopyMatching(query as CFDictionary, &dataTypeRef) == noErr {
            if let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        
        return nil
    }
    
    func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

#Preview {
    ContentView()
}


import SwiftUI
import SwiftUIX

struct AgentCommandView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var claudeService: ClaudeService
    @State private var commandText = ""
    @State private var isRunning = false
    @State private var selectedAgent = "Claude"
    @State private var showingInstructions = false
    
    let agents = ["Claude", "Codex", "Both"]
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            
            ScrollView {
                VStack(spacing: 20) {
                    commandInputSection
                    instructionsSection
                    historySection
                }
                .padding(20)
            }
            
            if isRunning {
                runningIndicator
            }
        }
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
            Image(systemName: "terminal.fill")
                .font(.system(size: 20))
                .foregroundColor(.green)
            
            Text("Agent Command Center")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            Picker("Agent", selection: $selectedAgent) {
                ForEach(agents, id: \.self) { agent in
                    Text(agent).tag(agent)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 200)
        }
        .padding()
        .background(Color.black.opacity(0.5))
    }
    
    var commandInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Command Input")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            VStack(spacing: 12) {
                TextEditor(text: $commandText)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .frame(minHeight: 100, maxHeight: 200)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                
                HStack(spacing: 12) {
                    GlassButton("Run Command") {
                        runCommand()
                    }
                    
                    GlassButton("Clear", isDestructive: true) {
                        commandText = ""
                    }
                    
                    Spacer()
                    
                    Button(action: { showingInstructions.toggle() }) {
                        Label("Instructions", systemImage: "info.circle")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .glassCard()
        .padding(.horizontal)
    }
    
    var instructionsSection: some View {
        Group {
            if showingInstructions {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Agent Instructions")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        instructionRow(icon: "checkmark.circle", text: "Use natural language to describe tasks")
                        instructionRow(icon: "cpu", text: "Claude handles code generation and analysis")
                        instructionRow(icon: "doc.text", text: "Codex specializes in code completion")
                        instructionRow(icon: "arrow.triangle.branch", text: "Commands are executed in repository context")
                        instructionRow(icon: "clock", text: "View real-time changes in the Live Changes panel")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.1))
                    )
                }
                .glassCard()
                .padding(.horizontal)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    func instructionRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
        }
    }
    
    var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Command History")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            if appState.currentSession?.commands.isEmpty ?? true {
                Text("No commands executed yet")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.4))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                ForEach(appState.currentSession?.commands ?? []) { command in
                    CommandHistoryRow(command: command)
                }
            }
        }
        .glassCard()
        .padding(.horizontal)
    }
    
    var runningIndicator: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(0.8)
            
            Text("Processing command...")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.purple.opacity(0.5), lineWidth: 1)
        )
        .padding()
    }
    
    func runCommand() {
        guard !commandText.isEmpty else { return }
        
        isRunning = true
        
        Task {
            do {
                if selectedAgent == "Claude" || selectedAgent == "Both" {
                    try await claudeService.executeCommand(commandText, for: appState.selectedRepository)
                }
                
                if selectedAgent == "Codex" || selectedAgent == "Both" {
                    // Codex integration would go here
                }
                
                commandText = ""
            } catch {
                appState.error = error.localizedDescription
            }
            
            isRunning = false
        }
    }
}

struct CommandHistoryRow: View {
    let command: AgentCommand
    @State private var isExpanded = false
    
    var statusColor: Color {
        switch command.status {
        case .completed: return .green
        case .failed: return .red
        case .running: return .yellow
        case .pending: return .gray
        }
    }
    
    var statusIcon: String {
        switch command.status {
        case .completed: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        case .running: return "arrow.circlepath"
        case .pending: return "clock.fill"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: statusIcon)
                    .font(.system(size: 14))
                    .foregroundColor(statusColor)
                
                Text(command.command)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(isExpanded ? nil : 1)
                
                Spacer()
                
                Text(command.timestamp, style: .time)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.4))
                
                Button(action: { isExpanded.toggle() }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.4))
                }
                .buttonStyle(.plain)
            }
            
            if isExpanded {
                if let output = command.output {
                    Text(output)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.03))
                        )
                }
                
                if let error = command.error {
                    Text(error)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.red.opacity(0.8))
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.red.opacity(0.1))
                        )
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.02))
        )
    }
}
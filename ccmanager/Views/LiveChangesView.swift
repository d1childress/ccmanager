import SwiftUI
import SwiftUIX

struct LiveChangesView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var githubService: GitHubService
    @State private var selectedChange: FileChange?
    @State private var autoRefresh = true
    @State private var refreshInterval: TimeInterval = 5
    
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            
            HSplitView {
                changesList
                    .frame(minWidth: 300, idealWidth: 400)
                
                if let change = selectedChange {
                    diffViewer(for: change)
                } else {
                    emptyDiffView
                }
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
        .onReceive(timer) { _ in
            if autoRefresh {
                refreshChanges()
            }
        }
    }
    
    var headerSection: some View {
        HStack {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .rotationEffect(.degrees(autoRefresh ? 360 : 0))
                .animation(autoRefresh ? .linear(duration: 2).repeatForever(autoreverses: false) : .default, value: autoRefresh)
            
            Text("Live Changes")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("Auto Refresh", isOn: $autoRefresh)
                .toggleStyle(SwitchToggleStyle())
                .labelsHidden()
            
            Text("Auto Refresh")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
            
            GlassButton("Refresh Now") {
                refreshChanges()
            }
        }
        .padding()
        .background(Color.black.opacity(0.5))
    }
    
    var changesList: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("File Changes")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                if let session = appState.currentSession {
                    Text("\(session.changes.count) changes")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding()
            .background(Color.black.opacity(0.3))
            
            ScrollView {
                LazyVStack(spacing: 4) {
                    if let changes = appState.currentSession?.changes {
                        ForEach(changes) { change in
                            ChangeRow(change: change, isSelected: selectedChange?.id == change.id)
                                .onTapGesture {
                                    selectedChange = change
                                }
                        }
                    } else {
                        Text("No changes detected")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.4))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                    }
                }
                .padding(8)
            }
        }
        .background(Color.black.opacity(0.2))
    }
    
    func diffViewer(for change: FileChange) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                
                Text(change.filePath)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                changeTypeBadge(change.changeType)
            }
            .padding()
            .background(Color.black.opacity(0.3))
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if let patch = change.patch {
                        DiffView(patch: patch)
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.white.opacity(0.2))
                            
                            Text("Diff not available")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.4))
                            
                            HStack(spacing: 40) {
                                StatView(label: "Additions", value: "+\(change.additions)", color: .green)
                                StatView(label: "Deletions", value: "-\(change.deletions)", color: .red)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(40)
                    }
                }
            }
            .background(Color.black.opacity(0.1))
        }
    }
    
    var emptyDiffView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(.white.opacity(0.1))
            
            Text("Select a file to view changes")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.4))
            
            Text("Changes will appear here in real-time as agents modify files")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.3))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.1))
    }
    
    func changeTypeBadge(_ type: FileChange.ChangeType) -> some View {
        Text(type.rawValue)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(colorForChangeType(type))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(colorForChangeType(type).opacity(0.2))
            )
    }
    
    func colorForChangeType(_ type: FileChange.ChangeType) -> Color {
        switch type {
        case .added: return .green
        case .modified: return .yellow
        case .deleted: return .red
        case .renamed: return .blue
        }
    }
    
    func refreshChanges() {
        Task {
            if let repo = appState.selectedRepository {
                do {
                    let changes = try await githubService.fetchChanges(for: repo)
                    await MainActor.run {
                        appState.setCurrentSessionChanges(changes)
                    }
                } catch {
                    await MainActor.run {
                        appState.error = error.localizedDescription
                    }
                }
            }
        }
    }
}

struct ChangeRow: View {
    let change: FileChange
    let isSelected: Bool
    
    var changeIcon: String {
        switch change.changeType {
        case .added: return "plus.circle.fill"
        case .modified: return "pencil.circle.fill"
        case .deleted: return "minus.circle.fill"
        case .renamed: return "arrow.triangle.2.circlepath"
        }
    }
    
    var changeColor: Color {
        switch change.changeType {
        case .added: return .green
        case .modified: return .yellow
        case .deleted: return .red
        case .renamed: return .blue
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: changeIcon)
                .font(.system(size: 16))
                .foregroundColor(changeColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(URL(fileURLWithPath: change.filePath).lastPathComponent)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.9))
                    .lineLimit(1)
                
                Text(change.filePath)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .white.opacity(0.5))
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 8) {
                    Text("+\(change.additions)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.green)
                    
                    Text("-\(change.deletions)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.red)
                }
                
                Text(change.timestamp, style: .time)
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.white.opacity(0.1) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isSelected ? changeColor.opacity(0.5) : Color.clear, lineWidth: 1)
        )
    }
}

struct DiffView: View {
    let patch: String
    
    var body: some View {
        let lines = patch.split(separator: "\n", omittingEmptySubsequences: false)
        return VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(lines.enumerated()), id: \.offset) { index, lineSub in
                let line = String(lineSub)
                DiffLine(line: line, lineNumber: index + 1)
            }
        }
        .padding()
    }
}

struct DiffLine: View {
    let line: String
    let lineNumber: Int
    
    var lineColor: Color {
        if line.hasPrefix("+") {
            return .green.opacity(0.2)
        } else if line.hasPrefix("-") {
            return .red.opacity(0.2)
        } else if line.hasPrefix("@@") {
            return .blue.opacity(0.2)
        } else {
            return .clear
        }
    }
    
    var textColor: Color {
        if line.hasPrefix("+") {
            return .green
        } else if line.hasPrefix("-") {
            return .red
        } else if line.hasPrefix("@@") {
            return .blue
        } else {
            return .white.opacity(0.7)
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Text("\(lineNumber)")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.white.opacity(0.3))
                .frame(width: 40, alignment: .trailing)
            
            Text(line)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 8)
        .background(lineColor)
    }
}

struct StatView: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .semibold, design: .monospaced))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
        }
    }
}
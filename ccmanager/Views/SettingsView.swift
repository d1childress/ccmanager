import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = "General"
    
    let tabs = ["General", "GitHub", "Claude", "Appearance"]
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            
            Picker("Category", selection: $selectedTab) {
                ForEach(tabs, id: \.self) { tab in
                    Text(tab).tag(tab)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            ScrollView {
                switch selectedTab {
                case "General":
                    generalSettings
                case "GitHub":
                    githubSettings
                case "Claude":
                    claudeSettings
                case "Appearance":
                    appearanceSettings
                default:
                    EmptyView()
                }
            }
        }
        .frame(width: 600, height: 500)
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
            Image(systemName: "gear")
                .font(.system(size: 24))
                .foregroundColor(.white.opacity(0.8))
            
            Text("Settings")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding()
        .background(Color.black.opacity(0.5))
    }
    
    var generalSettings: some View {
        VStack(alignment: .leading, spacing: 20) {
            SettingSection(title: "Default Settings") {
                SettingRow(label: "Default Local Path") {
                    HStack {
                        Text(appState.settings.defaultLocalPath)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        GlassButton("Change") {
                            changeDefaultPath()
                        }
                    }
                }
                
                SettingRow(label: "Auto Sync") {
                    Toggle("", isOn: $appState.settings.autoSync)
                        .toggleStyle(SwitchToggleStyle())
                        .labelsHidden()
                }
                
                SettingRow(label: "Sync Interval") {
                    Picker("", selection: $appState.settings.syncInterval) {
                        Text("1 min").tag(60.0)
                        Text("5 min").tag(300.0)
                        Text("10 min").tag(600.0)
                        Text("30 min").tag(1800.0)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 100)
                }
                
                SettingRow(label: "Show Notifications") {
                    Toggle("", isOn: $appState.settings.showNotifications)
                        .toggleStyle(SwitchToggleStyle())
                        .labelsHidden()
                }
            }
        }
        .padding()
    }
    
    var githubSettings: some View {
        VStack(alignment: .leading, spacing: 20) {
            SettingSection(title: "GitHub Configuration") {
                SettingRow(label: "Access Token") {
                    HStack {
                        if appState.settings.githubCredentials != nil {
                            Text("••••••••••••••••")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.white.opacity(0.5))
                        } else {
                            Text("Not configured")
                                .font(.system(size: 12))
                                .foregroundColor(.red.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        GlassButton("Update") {
                            // Show token input
                        }
                    }
                }
                
                SettingRow(label: "Username") {
                    Text(appState.settings.githubCredentials?.username ?? "Not set")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                SettingRow(label: "Connection Status") {
                    HStack {
                        Circle()
                            .fill(appState.settings.githubCredentials != nil ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        
                        Text(appState.settings.githubCredentials != nil ? "Connected" : "Disconnected")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            
            SettingSection(title: "Repository Defaults") {
                SettingRow(label: "Clone Strategy") {
                    Picker("", selection: .constant("HTTPS")) {
                        Text("HTTPS").tag("HTTPS")
                        Text("SSH").tag("SSH")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 150)
                }
                
                SettingRow(label: "Auto-fetch updates") {
                    Toggle("", isOn: .constant(true))
                        .toggleStyle(SwitchToggleStyle())
                        .labelsHidden()
                }
            }
        }
        .padding()
    }
    
    var claudeSettings: some View {
        VStack(alignment: .leading, spacing: 20) {
            SettingSection(title: "Claude API Configuration") {
                SettingRow(label: "API Key") {
                    HStack {
                        if appState.settings.claudeCredentials != nil {
                            Text("••••••••••••••••")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.white.opacity(0.5))
                        } else {
                            Text("Not configured")
                                .font(.system(size: 12))
                                .foregroundColor(.red.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        GlassButton("Update") {
                            // Show API key input
                        }
                    }
                }
                
                SettingRow(label: "Organization ID") {
                    Text(appState.settings.claudeCredentials?.organizationId ?? "Optional")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                SettingRow(label: "Model Preference") {
                    Picker("", selection: .constant("Claude 3 Opus")) {
                        Text("Claude 3 Opus").tag("opus")
                        Text("Claude 3 Sonnet").tag("sonnet")
                        Text("Claude 3 Haiku").tag("haiku")
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 150)
                }
            }
            
            SettingSection(title: "Usage Limits") {
                SettingRow(label: "Max Tokens per Request") {
                    Stepper("4096", value: .constant(4096), in: 1024...8192, step: 1024)
                        .frame(width: 120)
                }
                
                SettingRow(label: "Daily Token Limit") {
                    TextField("100000", text: .constant("100000"))
                        .textFieldStyle(.plain)
                        .frame(width: 100)
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.05))
                        )
                }
                
                SettingRow(label: "Cost Alerts") {
                    Toggle("", isOn: .constant(true))
                        .toggleStyle(SwitchToggleStyle())
                        .labelsHidden()
                }
            }
        }
        .padding()
    }
    
    var appearanceSettings: some View {
        VStack(alignment: .leading, spacing: 20) {
            SettingSection(title: "Theme") {
                SettingRow(label: "App Theme") {
                    Picker("", selection: $appState.settings.theme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 200)
                }
                
                SettingRow(label: "Transparency") {
                    Slider(value: .constant(0.95), in: 0.5...1.0)
                        .frame(width: 150)
                }
                
                SettingRow(label: "Blur Effect") {
                    Toggle("", isOn: .constant(true))
                        .toggleStyle(SwitchToggleStyle())
                        .labelsHidden()
                }
            }
            
            SettingSection(title: "Editor") {
                SettingRow(label: "Font Size") {
                    Stepper("12pt", value: .constant(12), in: 10...18)
                        .frame(width: 100)
                }
                
                SettingRow(label: "Line Numbers") {
                    Toggle("", isOn: .constant(true))
                        .toggleStyle(SwitchToggleStyle())
                        .labelsHidden()
                }
                
                SettingRow(label: "Syntax Highlighting") {
                    Toggle("", isOn: .constant(true))
                        .toggleStyle(SwitchToggleStyle())
                        .labelsHidden()
                }
            }
        }
        .padding()
    }
    
    func changeDefaultPath() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK, let url = panel.url {
            appState.settings.defaultLocalPath = url.path
            appState.saveSettings()
        }
    }
}

struct SettingSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            VStack(spacing: 16) {
                content
            }
            .padding()
            .glassCard()
        }
    }
}

struct SettingRow<Content: View>: View {
    let label: String
    let content: Content
    
    init(label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 150, alignment: .leading)
            
            Spacer()
            
            content
        }
    }
}
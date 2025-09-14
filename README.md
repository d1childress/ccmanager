# Claude Manager for macOS

A native macOS application for managing Claude Code and Codex with GitHub integration, featuring real-time change tracking and usage analytics.

## Features

### 🚀 Core Features
- **Native macOS App**: Built with SwiftUI for optimal performance and native look
- **GitHub Integration**: Connect and manage your repositories directly
- **Live Change Tracking**: See file changes in real-time as agents work
- **Agent Command Center**: Send commands to Claude and Codex agents
- **Usage Analytics**: Beautiful graphs showing token usage and costs
- **Liquid Glass UI**: Modern, semi-transparent design following Apple's design language

### 🎨 Design
- Black semi-transparent interface with blur effects
- Follows Apple's Liquid Glass UI design principles
- Smooth animations and transitions
- Dark mode optimized

### 📊 Analytics Dashboard
- Token usage tracking for Claude and Codex
- Cost estimation and tracking
- API call monitoring
- Historical usage graphs with multiple time ranges

### 🔄 Real-time Features
- Live file change detection
- Real-time diff viewer
- Auto-refresh capabilities
- Session management

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later
- Swift 5.9 or later
- GitHub account (for repository integration)
- Claude API key (for AI features)

## Installation

### Building from Source

1. Clone the repository:
```bash
git clone https://github.com/yourusername/claude-manager.git
cd claude-manager
```

2. Build with Swift Package Manager:
```bash
swift build -c release
```

3. Or open in Xcode:
```bash
open Package.swift
```

## Configuration

### GitHub Setup
1. Generate a GitHub personal access token
2. Open Settings in the app
3. Navigate to GitHub tab
4. Enter your token

### Claude API Setup
1. Get your Claude API key from Anthropic
2. Open Settings in the app
3. Navigate to Claude tab
4. Enter your API key

## Usage

### Adding Repositories
1. Click the + button in the sidebar
2. Choose from:
   - Search GitHub repositories
   - Enter repository URL
   - Select local repository

### Starting an Agent Session
1. Select a repository from the sidebar
2. Click "Start Agent Session"
3. Enter commands in natural language
4. View real-time changes in the Live Changes panel

### Viewing Usage Analytics
1. Click the Usage button in the sidebar
2. Select time range (24 hours, 7 days, 30 days, 3 months)
3. Toggle between Tokens, API Calls, and Cost views

## Architecture

The app is built with:
- **SwiftUI**: Native UI framework
- **Combine**: Reactive programming for data flow
- **Swift Charts**: Native charting library
- **URLSession**: Network requests
- **Process**: Git integration

### Project Structure
```
ClaudeManager/
├── App/                 # Main app entry points
├── Views/              # SwiftUI views
├── ViewModels/         # Observable state management
├── Models/             # Data models
├── Services/           # API and service layers
├── Components/         # Reusable UI components
└── Resources/          # Assets and resources
```

## Contributing

Contributions are welcome! Please feel free to submit pull requests.

## License

MIT License - See LICENSE file for details

## Acknowledgments

- Built for the Claude and Codex developer community
- Inspired by Apple's design guidelines
- Uses SwiftUI's latest features for macOS
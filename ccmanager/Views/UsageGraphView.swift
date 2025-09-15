import SwiftUI
import Charts
import SwiftUIX

struct UsageGraphView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTimeRange = "7 Days"
    @State private var selectedMetric = "Tokens"
    @State private var hoveredData: UsageData?
    
    let timeRanges = ["24 Hours", "7 Days", "30 Days", "3 Months"]
    let metrics = ["Tokens", "API Calls", "Cost"]
    
    var filteredData: [UsageData] {
        let now = Date()
        let cutoff: Date
        
        switch selectedTimeRange {
        case "24 Hours":
            cutoff = now.addingTimeInterval(-86400)
        case "7 Days":
            cutoff = now.addingTimeInterval(-604800)
        case "30 Days":
            cutoff = now.addingTimeInterval(-2592000)
        case "3 Months":
            cutoff = now.addingTimeInterval(-7776000)
        default:
            cutoff = now.addingTimeInterval(-604800)
        }
        
        return appState.usageHistory.filter { $0.date >= cutoff }
    }
    
    var totalClaude: Int {
        filteredData.reduce(0) { $0 + $1.claudeTokens }
    }
    
    var totalCodex: Int {
        filteredData.reduce(0) { $0 + $1.codexTokens }
    }
    
    var totalCost: Double {
        filteredData.reduce(0) { $0 + $1.cost }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            
            ScrollView {
                VStack(spacing: 20) {
                    statsCards
                    mainChart
                    detailsSection
                }
                .padding(20)
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
        .onAppear {
            loadMockData()
        }
    }
    
    var headerSection: some View {
        HStack {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 20))
                .foregroundColor(.purple)
            
            Text("Usage Analytics")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            Picker("Time Range", selection: $selectedTimeRange) {
                ForEach(timeRanges, id: \.self) { range in
                    Text(range).tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 300)
            
            Picker("Metric", selection: $selectedMetric) {
                ForEach(metrics, id: \.self) { metric in
                    Text(metric).tag(metric)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 200)
        }
        .padding()
        .background(Color.black.opacity(0.5))
    }
    
    var statsCards: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Claude Tokens",
                value: formatNumber(totalClaude),
                icon: "brain",
                color: .blue,
                subtitle: "Total usage"
            )
            
            StatCard(
                title: "Codex Tokens",
                value: formatNumber(totalCodex),
                icon: "cpu",
                color: .green,
                subtitle: "Total usage"
            )
            
            StatCard(
                title: "API Calls",
                value: formatNumber(filteredData.reduce(0) { $0 + $1.apiCalls }),
                icon: "network",
                color: .orange,
                subtitle: "Total requests"
            )
            
            StatCard(
                title: "Total Cost",
                value: String(format: "$%.2f", totalCost),
                icon: "dollarsign.circle",
                color: .purple,
                subtitle: "Estimated"
            )
        }
    }
    
    var mainChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Usage Over Time")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            Chart(filteredData) { data in
                if selectedMetric == "Tokens" {
                    LineMark(
                        x: .value("Date", data.date),
                        y: .value("Claude", data.claudeTokens)
                    )
                    .foregroundStyle(.blue)
                    .interpolationMethod(.catmullRom)
                    
                    LineMark(
                        x: .value("Date", data.date),
                        y: .value("Codex", data.codexTokens)
                    )
                    .foregroundStyle(.green)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Date", data.date),
                        y: .value("Claude", data.claudeTokens)
                    )
                    .foregroundStyle(.blue.opacity(0.1))
                    
                    AreaMark(
                        x: .value("Date", data.date),
                        y: .value("Codex", data.codexTokens)
                    )
                    .foregroundStyle(.green.opacity(0.1))
                } else if selectedMetric == "API Calls" {
                    BarMark(
                        x: .value("Date", data.date),
                        y: .value("Calls", data.apiCalls)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(4)
                } else {
                    LineMark(
                        x: .value("Date", data.date),
                        y: .value("Cost", data.cost)
                    )
                    .foregroundStyle(.purple)
                    .interpolationMethod(.catmullRom)
                    
                    PointMark(
                        x: .value("Date", data.date),
                        y: .value("Cost", data.cost)
                    )
                    .foregroundStyle(.purple)
                }
            }
            .frame(height: 300)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.6))
                    AxisGridLine()
                        .foregroundStyle(.white.opacity(0.1))
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.6))
                    AxisGridLine()
                        .foregroundStyle(.white.opacity(0.1))
                }
            }
            .chartBackground { _ in
                Color.white.opacity(0.02)
            }
            .padding()
            .glassCard()
        }
    }
    
    var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Usage Breakdown")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            HStack(spacing: 20) {
                UsageBreakdown(
                    title: "Claude",
                    percentage: Double(totalClaude) / Double(totalClaude + totalCodex),
                    color: .blue
                )
                
                UsageBreakdown(
                    title: "Codex",
                    percentage: Double(totalCodex) / Double(totalClaude + totalCodex),
                    color: .green
                )
            }
            .padding()
            .glassCard()
            
            Text("Recent Activity")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .padding(.top)
            
            VStack(spacing: 8) {
                ForEach(filteredData.suffix(5).reversed()) { data in
                    ActivityRow(data: data)
                }
            }
            .padding()
            .glassCard()
        }
    }
    
    func formatNumber(_ number: Int) -> String {
        if number >= 1_000_000 {
            return String(format: "%.1fM", Double(number) / 1_000_000)
        } else if number >= 1_000 {
            return String(format: "%.1fK", Double(number) / 1_000)
        } else {
            return String(number)
        }
    }
    
    func loadMockData() {
        var mockData: [UsageData] = []
        let now = Date()
        
        for i in 0..<30 {
            let date = now.addingTimeInterval(TimeInterval(-i * 86400))
            let claudeTokens = Int.random(in: 1000...50000)
            let codexTokens = Int.random(in: 500...30000)
            let apiCalls = Int.random(in: 10...200)
            let cost = Double(claudeTokens) * 0.00002 + Double(codexTokens) * 0.00001
            
            mockData.append(UsageData(
                date: date,
                claudeTokens: claudeTokens,
                codexTokens: codexTokens,
                apiCalls: apiCalls,
                cost: cost
            ))
        }
        
        appState.usageHistory = mockData
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.4))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .glassCard()
    }
}

struct UsageBreakdown: View {
    let title: String
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text(String(format: "%.1f%%", percentage * 100))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * percentage)
                }
            }
            .frame(height: 8)
        }
    }
}

struct ActivityRow: View {
    let data: UsageData
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(data.date, style: .date)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("\(data.apiCalls) API calls")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Label("\(data.claudeTokens)", systemImage: "brain")
                    .font(.system(size: 10))
                    .foregroundColor(.blue)
                
                Label("\(data.codexTokens)", systemImage: "cpu")
                    .font(.system(size: 10))
                    .foregroundColor(.green)
                
                Text(String(format: "$%.2f", data.cost))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.purple)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white.opacity(0.02))
        )
    }
}
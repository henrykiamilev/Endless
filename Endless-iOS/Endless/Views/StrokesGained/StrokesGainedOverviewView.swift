import SwiftUI

// MARK: - Strokes Gained Overview View

struct StrokesGainedOverviewView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel = StrokesGainedViewModel.shared
    @State private var selectedCategory: SGCategory?
    @State private var selectedTab: StatRowModel.StatCategory = .scoring

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header
                headerSection

                // Total SG Card
                totalSGCard

                // Category Tiles
                categoryTilesSection

                // Tab Bar for Stats Tables
                statsTabBar

                // Current Stats Table
                currentStatsTable

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
        .background(themeManager.theme.background)
        .sheet(item: $selectedCategory) { category in
            CategoryDetailView(category: category)
                .environmentObject(themeManager)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Strokes Gained")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(themeManager.theme.textPrimary)

                Text("Performance Analytics")
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.theme.textSecondary)
            }

            Spacer()

            // Timeframe selector
            Menu {
                ForEach(StatTimeframe.allCases, id: \.self) { timeframe in
                    Button(action: {
                        viewModel.setTimeframe(timeframe)
                    }) {
                        Text(timeframe.rawValue)
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(viewModel.selectedTimeframe.rawValue)
                        .font(.system(size: 13, weight: .medium))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                }
                .foregroundColor(themeManager.theme.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(themeManager.theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.top, 16)
    }

    // MARK: - Total SG Card

    private var totalSGCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Total Strokes Gained")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(themeManager.theme.textSecondary)

                Spacer()

                if let summary = viewModel.currentSummary {
                    Text(formatSG(summary.totalStrokesGained))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(sgColor(for: summary.totalStrokesGained))
                }
            }

            // SG Breakdown Bar
            if let summary = viewModel.currentSummary {
                sgBreakdownBar(summary: summary)
            }
        }
        .padding(20)
        .background(themeManager.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(themeManager.isDark ? 0.3 : 0.08), radius: 16, x: 0, y: 8)
    }

    private func sgBreakdownBar(summary: RoundSummary) -> some View {
        VStack(spacing: 8) {
            // Stacked bar
            GeometryReader { geometry in
                HStack(spacing: 2) {
                    ForEach(SGCategory.allCases, id: \.self) { category in
                        let sg = summary.sg(for: category)
                        let width = barWidth(for: sg, total: totalAbsSG(summary), totalWidth: geometry.size.width)

                        Rectangle()
                            .fill(categoryColor(for: category, sg: sg))
                            .frame(width: max(width, 4))
                    }
                }
            }
            .frame(height: 8)
            .clipShape(RoundedRectangle(cornerRadius: 4))

            // Legend
            HStack(spacing: 16) {
                ForEach(SGCategory.allCases, id: \.self) { category in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(categoryBaseColor(for: category))
                            .frame(width: 8, height: 8)

                        Text(category.displayName)
                            .font(.system(size: 10))
                            .foregroundColor(themeManager.theme.textMuted)

                        Text(formatSG(summary.sg(for: category)))
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(sgColor(for: summary.sg(for: category)))
                    }
                }
            }
        }
    }

    // MARK: - Category Tiles Section

    private var categoryTilesSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            ForEach(SGCategory.allCases, id: \.self) { category in
                categoryTile(category: category)
            }
        }
    }

    private func categoryTile(category: SGCategory) -> some View {
        Button(action: { selectedCategory = category }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: category.icon)
                        .font(.system(size: 18))
                        .foregroundColor(categoryBaseColor(for: category))

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.theme.textMuted)
                }

                Text(category.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.theme.textPrimary)

                if let summary = viewModel.currentSummary {
                    Text(formatSG(summary.sg(for: category)))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(sgColor(for: summary.sg(for: category)))
                }
            }
            .padding(16)
            .background(themeManager.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(categoryBaseColor(for: category).opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Stats Tab Bar

    private var statsTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(StatRowModel.StatCategory.allCases, id: \.self) { tab in
                    Button(action: { selectedTab = tab }) {
                        VStack(spacing: 8) {
                            Text(tab.rawValue)
                                .font(.system(size: 14, weight: selectedTab == tab ? .semibold : .regular))
                                .foregroundColor(selectedTab == tab ? themeManager.theme.accentGreen : themeManager.theme.textMuted)

                            Rectangle()
                                .fill(selectedTab == tab ? themeManager.theme.accentGreen : Color.clear)
                                .frame(height: 3)
                        }
                        .padding(.horizontal, 16)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .background(themeManager.theme.cardBackground)
    }

    // MARK: - Current Stats Table

    private var currentStatsTable: some View {
        Group {
            switch selectedTab {
            case .scoring:
                statsTableView(title: "Scoring", rows: viewModel.scoringRows)
            case .tee:
                statsTableView(title: "Tee", rows: viewModel.teeRows)
            case .approach:
                statsTableView(title: "Approach", rows: viewModel.approachRows)
            case .shortGame:
                statsTableView(title: "Short Game", rows: viewModel.shortGameRows)
            case .putting:
                statsTableView(title: "Putting", rows: viewModel.puttingRows)
            }
        }
    }

    private func statsTableView(title: String, rows: [StatRowModel]) -> some View {
        VStack(spacing: 0) {
            // Colored bar
            Rectangle()
                .fill(tabColor(for: selectedTab))
                .frame(height: 4)

            // Table Header
            HStack(spacing: 0) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.theme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)

                ForEach([StatTimeframe.lastRound, .last3, .last4, .last20, .season], id: \.self) { timeframe in
                    Text(timeframe.rawValue)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(themeManager.theme.textSecondary)
                        .frame(width: timeframe == .lastRound ? 60 : 50, alignment: .trailing)
                }
            }
            .padding(.vertical, 10)
            .padding(.trailing, 12)
            .background(themeManager.theme.cardBackground)
            .overlay(
                Rectangle()
                    .fill(themeManager.theme.border)
                    .frame(height: 1),
                alignment: .bottom
            )

            // Rows
            ForEach(Array(rows.enumerated()), id: \.element.id) { index, stat in
                HStack(spacing: 0) {
                    Text(stat.label)
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)

                    ForEach([StatTimeframe.lastRound, .last3, .last4, .last20, .season], id: \.self) { timeframe in
                        VStack(spacing: 1) {
                            Text(stat.displayValue(for: timeframe))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(valueColor(for: stat, timeframe: timeframe))

                            Text("\(stat.sampleSize(for: timeframe))")
                                .font(.system(size: 9))
                                .foregroundColor(themeManager.theme.textMuted)
                        }
                        .frame(width: timeframe == .lastRound ? 60 : 50, alignment: .trailing)
                    }
                }
                .padding(.vertical, 8)
                .padding(.trailing, 12)
                .background(index % 2 == 1 ? themeManager.theme.background.opacity(0.5) : themeManager.theme.cardBackground)
            }
        }
        .background(themeManager.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Helpers

    private func formatSG(_ value: Double) -> String {
        if value >= 0 {
            return String(format: "+%.2f", value)
        } else {
            return String(format: "%.2f", value)
        }
    }

    private func sgColor(for value: Double) -> Color {
        if value > 0.1 {
            return themeManager.theme.accentGreen
        } else if value < -0.1 {
            return themeManager.theme.error
        }
        return themeManager.theme.textPrimary
    }

    private func categoryBaseColor(for category: SGCategory) -> Color {
        switch category {
        case .offTheTee: return .green
        case .approach: return .orange
        case .shortGame: return .cyan
        case .putting: return .blue
        }
    }

    private func categoryColor(for category: SGCategory, sg: Double) -> Color {
        let base = categoryBaseColor(for: category)
        return sg >= 0 ? base : base.opacity(0.5)
    }

    private func totalAbsSG(_ summary: RoundSummary) -> Double {
        abs(summary.sgOffTheTee) + abs(summary.sgApproach) + abs(summary.sgShortGame) + abs(summary.sgPutting)
    }

    private func barWidth(for sg: Double, total: Double, totalWidth: CGFloat) -> CGFloat {
        guard total > 0 else { return totalWidth / 4 }
        return (abs(sg) / total) * totalWidth
    }

    private func tabColor(for tab: StatRowModel.StatCategory) -> Color {
        switch tab {
        case .scoring: return .gray
        case .tee: return .green
        case .approach: return .red
        case .shortGame: return .green
        case .putting: return .blue
        }
    }

    private func valueColor(for stat: StatRowModel, timeframe: StatTimeframe) -> Color {
        guard stat.displayType == .strokesGained,
              let value = stat.values[timeframe]?.value else {
            return themeManager.theme.textPrimary
        }

        if value > 0.1 { return .green }
        if value < -0.1 { return .red }
        return themeManager.theme.textPrimary
    }
}

// MARK: - Preview

struct StrokesGainedOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        StrokesGainedOverviewView()
            .environmentObject(ThemeManager())
    }
}

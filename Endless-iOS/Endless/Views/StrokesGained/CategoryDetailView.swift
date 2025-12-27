import SwiftUI

// MARK: - Category Detail View
// Displays detailed statistics for each Strokes Gained category
// Layout matches the professional golf stats table format

struct CategoryDetailView: View {
    let category: SGCategory
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel = StrokesGainedViewModel.shared

    // Selected timeframe columns to display
    let timeframes: [StatTimeframe] = [.lastRound, .last3, .last4, .last20, .season]

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Category Header
                    categoryHeader

                    // Stats Table
                    statsTable
                }
            }
            .background(themeManager.theme.background)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(category.displayName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(themeManager.theme.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(themeManager.theme.cardBackground)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }

    // MARK: - Category Header

    private var categoryHeader: some View {
        VStack(spacing: 0) {
            // Colored bar indicator
            Rectangle()
                .fill(categoryColor)
                .frame(height: 4)

            // Tab bar mimicking screenshot
            HStack(spacing: 0) {
                ForEach(SGCategory.allCases, id: \.self) { cat in
                    Button(action: {}) {
                        Text(cat.displayName)
                            .font(.system(size: 13, weight: cat == category ? .semibold : .regular))
                            .foregroundColor(cat == category ? themeManager.theme.textPrimary : themeManager.theme.textMuted)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 8)
                    }
                    .disabled(cat != category)
                }
            }
            .background(themeManager.theme.cardBackground)
        }
    }

    // MARK: - Stats Table

    private var statsTable: some View {
        VStack(spacing: 0) {
            // Table Header
            tableHeader

            // Stats Rows
            ForEach(Array(categoryStats.enumerated()), id: \.element.id) { index, stat in
                statRow(stat: stat, isAlternate: index % 2 == 1)
            }
        }
        .background(themeManager.theme.cardBackground)
    }

    private var tableHeader: some View {
        HStack(spacing: 0) {
            // Stat name column
            Text(category.displayName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(themeManager.theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)

            // Timeframe columns
            ForEach(timeframes, id: \.self) { timeframe in
                Text(timeframe.rawValue)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(themeManager.theme.textSecondary)
                    .frame(width: columnWidth(for: timeframe), alignment: .trailing)
            }
        }
        .padding(.vertical, 12)
        .padding(.trailing, 12)
        .background(themeManager.theme.cardBackground)
        .overlay(
            Rectangle()
                .fill(themeManager.theme.border)
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private func statRow(stat: StatRowModel, isAlternate: Bool) -> some View {
        HStack(spacing: 0) {
            // Stat label
            Text(stat.label)
                .font(.system(size: 13))
                .foregroundColor(themeManager.theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 24)

            // Values for each timeframe
            ForEach(timeframes, id: \.self) { timeframe in
                VStack(spacing: 2) {
                    Text(stat.displayValue(for: timeframe))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(valueColor(for: stat, timeframe: timeframe))

                    Text("\(stat.sampleSize(for: timeframe))")
                        .font(.system(size: 10))
                        .foregroundColor(themeManager.theme.textMuted)
                }
                .frame(width: columnWidth(for: timeframe), alignment: .trailing)
            }
        }
        .padding(.vertical, 10)
        .padding(.trailing, 12)
        .background(isAlternate ? themeManager.theme.background.opacity(0.5) : themeManager.theme.cardBackground)
    }

    // MARK: - Helpers

    private var categoryStats: [StatRowModel] {
        viewModel.stats(for: category)
    }

    private var categoryColor: Color {
        switch category {
        case .offTheTee: return .green
        case .approach: return .red
        case .shortGame: return .green
        case .putting: return .blue
        }
    }

    private func columnWidth(for timeframe: StatTimeframe) -> CGFloat {
        switch timeframe {
        case .lastRound: return 65
        case .last3: return 50
        case .last4: return 50
        case .last20: return 55
        case .season: return 55
        }
    }

    private func valueColor(for stat: StatRowModel, timeframe: StatTimeframe) -> Color {
        guard stat.displayType == .strokesGained,
              let value = stat.values[timeframe]?.value else {
            return themeManager.theme.textPrimary
        }

        if value > 0.1 {
            return .green
        } else if value < -0.1 {
            return .red
        }
        return themeManager.theme.textPrimary
    }
}

// MARK: - Scoring Stats View (For Overview Tab)

struct ScoringStatsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel = StrokesGainedViewModel.shared

    let timeframes: [StatTimeframe] = [.lastRound, .last3, .last4, .last20, .season]

    var body: some View {
        VStack(spacing: 0) {
            // Table Header
            tableHeader

            // Stats Rows
            ForEach(Array(viewModel.scoringRows.enumerated()), id: \.element.id) { index, stat in
                statRow(stat: stat, isAlternate: index % 2 == 1)
            }
        }
        .background(themeManager.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var tableHeader: some View {
        HStack(spacing: 0) {
            Text("Scoring")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(themeManager.theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)

            ForEach(timeframes, id: \.self) { timeframe in
                Text(timeframe.rawValue)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(themeManager.theme.textSecondary)
                    .frame(width: 55, alignment: .trailing)
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
    }

    private func statRow(stat: StatRowModel, isAlternate: Bool) -> some View {
        HStack(spacing: 0) {
            Text(stat.label)
                .font(.system(size: 12))
                .foregroundColor(themeManager.theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)

            ForEach(timeframes, id: \.self) { timeframe in
                VStack(spacing: 1) {
                    Text(stat.displayValue(for: timeframe))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(valueColor(for: stat, timeframe: timeframe))

                    Text("\(stat.sampleSize(for: timeframe))")
                        .font(.system(size: 9))
                        .foregroundColor(themeManager.theme.textMuted)
                }
                .frame(width: 55, alignment: .trailing)
            }
        }
        .padding(.vertical, 8)
        .padding(.trailing, 12)
        .background(isAlternate ? themeManager.theme.background.opacity(0.5) : themeManager.theme.cardBackground)
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

struct CategoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryDetailView(category: .putting)
            .environmentObject(ThemeManager())
    }
}

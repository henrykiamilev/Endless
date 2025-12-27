import SwiftUI

// MARK: - Trends View

struct TrendsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel = StrokesGainedViewModel.shared

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Period Cards
                    if viewModel.trends.isEmpty {
                        emptyState
                    } else {
                        ForEach(viewModel.trends) { trend in
                            trendCard(trend)
                        }
                    }

                    // Category Trends Chart Placeholder
                    categoryTrendsSection

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(themeManager.theme.background)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Strokes Gained Trends")
                        .font(.system(size: 17, weight: .bold))
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

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundColor(themeManager.theme.textMuted)

            Text("No Trend Data Yet")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(themeManager.theme.textPrimary)

            Text("Complete more rounds to see your strokes gained trends over time.")
                .font(.system(size: 14))
                .foregroundColor(themeManager.theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .padding(.horizontal, 20)
        .background(themeManager.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    // MARK: - Trend Card

    private func trendCard(_ trend: TrendsCalculator.TrendData) -> some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(trend.period)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Text("\(trend.roundCount) round\(trend.roundCount == 1 ? "" : "s")")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.theme.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Avg SG/Round")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(themeManager.theme.textMuted)

                    Text(formatSG(trend.averageSGPerRound))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(sgColor(for: trend.averageSGPerRound))
                }
            }

            Divider()
                .background(themeManager.theme.border)

            // Category breakdown
            HStack(spacing: 0) {
                ForEach(SGCategory.allCases, id: \.self) { category in
                    let sg = trend.sgByCategory[category] ?? 0
                    categoryMiniCard(category: category, sg: sg)

                    if category != SGCategory.allCases.last {
                        Divider()
                            .frame(height: 40)
                            .background(themeManager.theme.border)
                    }
                }
            }
        }
        .padding(16)
        .background(themeManager.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func categoryMiniCard(category: SGCategory, sg: Double) -> some View {
        VStack(spacing: 6) {
            Image(systemName: category.icon)
                .font(.system(size: 14))
                .foregroundColor(sgColor(for: sg))

            Text(formatSG(sg))
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(sgColor(for: sg))

            Text(category.rawValue)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(themeManager.theme.textMuted)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Category Trends Section

    private var categoryTrendsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CATEGORY TRENDS")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundColor(themeManager.theme.textSecondary)

            VStack(spacing: 12) {
                ForEach(SGCategory.allCases, id: \.self) { category in
                    categoryTrendRow(category)
                }
            }
            .padding(16)
            .background(themeManager.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private func categoryTrendRow(_ category: SGCategory) -> some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.system(size: 16))
                .foregroundColor(themeManager.theme.accentGreen)
                .frame(width: 36, height: 36)
                .background(themeManager.theme.accentGreen.opacity(0.15))
                .clipShape(Circle())

            Text(category.displayName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.theme.textPrimary)

            Spacer()

            // Mini trend line placeholder
            trendLineView(for: category)
                .frame(width: 60, height: 24)

            // Current value
            if let latestTrend = viewModel.trends.first {
                let sg = latestTrend.sgByCategory[category] ?? 0
                Text(formatSG(sg))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(sgColor(for: sg))
                    .frame(width: 55, alignment: .trailing)
            }
        }
    }

    private func trendLineView(for category: SGCategory) -> some View {
        // Simplified trend line visualization
        GeometryReader { geo in
            Path { path in
                let values = viewModel.trends.compactMap { $0.sgByCategory[category] }
                guard values.count >= 2 else { return }

                let minVal = values.min() ?? 0
                let maxVal = values.max() ?? 0
                let range = maxVal - minVal
                let step = geo.size.width / CGFloat(values.count - 1)

                for (index, value) in values.enumerated() {
                    let x = CGFloat(index) * step
                    let normalizedY = range > 0 ? (value - minVal) / range : 0.5
                    let y = geo.size.height * (1 - CGFloat(normalizedY))

                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(themeManager.theme.accentGreen, lineWidth: 2)
        }
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
        if value > 0.3 {
            return themeManager.theme.accentGreen
        } else if value < -0.3 {
            return themeManager.theme.error
        } else {
            return themeManager.theme.textPrimary
        }
    }
}

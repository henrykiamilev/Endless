import SwiftUI

// MARK: - Strokes Gained Overview View

struct StrokesGainedOverviewView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel = StrokesGainedViewModel.shared
    @State private var selectedCategory: SGCategory?
    @State private var showingHoleDetail = false
    @State private var selectedHoleNumber: Int?
    @State private var showingTrends = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header
                headerSection

                // Total SG Card
                totalSGCard

                // Category Tiles
                categoryTilesSection

                // Insights Section
                insightsSection

                // Quick Actions
                quickActionsSection

                // Confidence Badge
                confidenceBadge

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
        .background(themeManager.theme.background)
        .sheet(item: $selectedCategory) { category in
            CategoryDetailView(category: category)
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingTrends) {
            TrendsView()
                .environmentObject(themeManager)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("STROKES GAINED")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(themeManager.theme.textSecondary)

                if let summary = viewModel.currentSummary {
                    Text(summary.courseName ?? "Recent Round")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)
                } else {
                    Text("No Round Data")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)
                }
            }

            Spacer()

            Button(action: { showingTrends = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 14))
                    Text("Trends")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(themeManager.theme.accentGreen)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(themeManager.theme.accentGreen.opacity(0.15))
                .clipShape(Capsule())
            }
        }
        .padding(.top, 16)
    }

    // MARK: - Total SG Card

    private var totalSGCard: some View {
        VStack(spacing: 16) {
            // Main SG Value
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Strokes Gained")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.theme.textSecondary)

                    if let summary = viewModel.currentSummary {
                        Text(summary.formattedTotalSG)
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(sgColor(for: summary.totalSG))
                    } else {
                        Text("--")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(themeManager.theme.textMuted)
                    }
                }

                Spacer()

                // SG Equation
                VStack(alignment: .trailing, spacing: 4) {
                    Text("SG Formula")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(themeManager.theme.textMuted)

                    Text("Expected(start) - Expected(end) - 1")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(themeManager.theme.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(themeManager.theme.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }

            Divider()
                .background(themeManager.theme.border)

            // Biggest Strength/Leak
            HStack(spacing: 20) {
                if let summary = viewModel.currentSummary {
                    // Biggest Strength
                    if let strength = summary.biggestStrength {
                        strengthLeakItem(
                            title: "Biggest Strength",
                            category: strength,
                            value: summary.sgByCategory[strength] ?? 0,
                            isStrength: true
                        )
                    }

                    Spacer()

                    // Biggest Leak
                    if let leak = summary.biggestLeak {
                        strengthLeakItem(
                            title: "Biggest Leak",
                            category: leak,
                            value: summary.sgByCategory[leak] ?? 0,
                            isStrength: false
                        )
                    }
                } else {
                    Text("Complete a round to see insights")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.theme.textMuted)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(20)
        .background(themeManager.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(themeManager.isDark ? 0.3 : 0.08), radius: 16, x: 0, y: 8)
    }

    private func strengthLeakItem(title: String, category: SGCategory, value: Double, isStrength: Bool) -> some View {
        VStack(alignment: isStrength ? .leading : .trailing, spacing: 6) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .tracking(0.5)
                .foregroundColor(themeManager.theme.textMuted)

            HStack(spacing: 8) {
                if !isStrength {
                    Text(formatSG(value))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(sgColor(for: value))
                }

                Image(systemName: category.icon)
                    .font(.system(size: 16))
                    .foregroundColor(isStrength ? themeManager.theme.accentGreen : themeManager.theme.error)
                    .frame(width: 32, height: 32)
                    .background((isStrength ? themeManager.theme.accentGreen : themeManager.theme.error).opacity(0.15))
                    .clipShape(Circle())

                if isStrength {
                    Text(formatSG(value))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(sgColor(for: value))
                }
            }

            Text(category.displayName)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(themeManager.theme.textSecondary)
        }
    }

    // MARK: - Category Tiles

    private var categoryTilesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("BY CATEGORY")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundColor(themeManager.theme.textSecondary)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(SGCategory.allCases, id: \.self) { category in
                    categoryTile(category)
                }
            }
        }
    }

    private func categoryTile(_ category: SGCategory) -> some View {
        Button(action: { selectedCategory = category }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: category.icon)
                        .font(.system(size: 18))
                        .foregroundColor(themeManager.theme.accentGreen)
                        .frame(width: 36, height: 36)
                        .background(themeManager.theme.accentGreen.opacity(0.15))
                        .clipShape(Circle())

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(themeManager.theme.textMuted)
                }

                VStack(alignment: .leading, spacing: 4) {
                    if let summary = viewModel.currentSummary {
                        let sg = summary.sgByCategory[category] ?? 0
                        Text(formatSG(sg))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(sgColor(for: sg))
                    } else {
                        Text("--")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(themeManager.theme.textMuted)
                    }

                    Text(category.displayName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(themeManager.theme.textSecondary)
                }
            }
            .padding(16)
            .background(themeManager.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Insights Section

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("FOCUS POINTS")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundColor(themeManager.theme.textSecondary)

            if viewModel.focusPoints.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "lightbulb")
                        .font(.system(size: 28))
                        .foregroundColor(themeManager.theme.textMuted)

                    Text("Complete a round to get personalized insights")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(themeManager.theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.focusPoints) { insight in
                        insightRow(insight)
                    }
                }
            }
        }
    }

    private func insightRow(_ insight: InsightCard) -> some View {
        HStack(spacing: 14) {
            Image(systemName: insight.category?.icon ?? "lightbulb.fill")
                .font(.system(size: 16))
                .foregroundColor(themeManager.theme.accentGreen)
                .frame(width: 40, height: 40)
                .background(themeManager.theme.accentGreen.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.theme.textPrimary)

                Text(insight.description)
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.theme.textSecondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(14)
        .background(themeManager.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("EXPLORE")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundColor(themeManager.theme.textSecondary)

            HStack(spacing: 12) {
                quickActionButton(
                    icon: "list.number",
                    title: "Shot Table",
                    action: { /* Navigate to hole detail */ }
                )

                quickActionButton(
                    icon: "ruler",
                    title: "Distance Bands",
                    action: { selectedCategory = .approach }
                )

                quickActionButton(
                    icon: "circle.fill",
                    title: "Putting Bands",
                    action: { selectedCategory = .putting }
                )
            }
        }
    }

    private func quickActionButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(themeManager.theme.textPrimary)

                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(themeManager.theme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(themeManager.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Confidence Badge

    private var confidenceBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 14))
                .foregroundColor(themeManager.theme.accentGreen)

            if let summary = viewModel.currentSummary {
                Text(summary.confidenceStats.autoConfirmedPercent)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(themeManager.theme.textSecondary)
            } else {
                Text("No data yet")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(themeManager.theme.textMuted)
            }

            Spacer()

            if let summary = viewModel.currentSummary, summary.confidenceStats.needsReviewShots > 0 {
                Text("\(summary.confidenceStats.needsReviewShots) needs review")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(themeManager.theme.error)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(themeManager.theme.error.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(themeManager.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
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
        if value > 0.5 {
            return themeManager.theme.accentGreen
        } else if value < -0.5 {
            return themeManager.theme.error
        } else {
            return themeManager.theme.textPrimary
        }
    }
}

// MARK: - SGCategory Identifiable Extension

extension SGCategory: Identifiable {
    var id: String { rawValue }
}

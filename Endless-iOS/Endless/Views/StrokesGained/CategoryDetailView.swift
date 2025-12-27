import SwiftUI

// MARK: - Category Detail View

struct CategoryDetailView: View {
    let category: SGCategory
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel = StrokesGainedViewModel.shared
    @State private var selectedShot: ShotRowModel?

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header Card
                    headerCard

                    // Distance/Putting Bands
                    bandsSection

                    // Top Shots (Best & Worst)
                    topShotsSection

                    // All Shots in Category
                    allShotsSection

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
                    HStack(spacing: 8) {
                        Image(systemName: category.icon)
                            .font(.system(size: 14))
                            .foregroundColor(themeManager.theme.accentGreen)
                        Text(category.displayName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(themeManager.theme.textPrimary)
                    }
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
            .sheet(item: $selectedShot) { shot in
                ShotDetailEditorView(shot: shot)
                    .environmentObject(themeManager)
            }
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: category.icon)
                    .font(.system(size: 24))
                    .foregroundColor(themeManager.theme.accentGreen)
                    .frame(width: 52, height: 52)
                    .background(themeManager.theme.accentGreen.opacity(0.15))
                    .clipShape(Circle())

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total SG")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(themeManager.theme.textMuted)

                    if let summary = viewModel.currentSummary {
                        let sg = summary.sgByCategory[category] ?? 0
                        Text(formatSG(sg))
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(sgColor(for: sg))
                    } else {
                        Text("--")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(themeManager.theme.textMuted)
                    }
                }
            }

            Divider()
                .background(themeManager.theme.border)

            HStack {
                statItem(label: "Shots", value: "\(categoryShots.count)")

                Divider()
                    .frame(height: 30)
                    .background(themeManager.theme.border)

                statItem(label: "Avg SG/Shot", value: avgSGPerShot)

                Divider()
                    .frame(height: 30)
                    .background(themeManager.theme.border)

                statItem(label: "High Conf", value: "\(highConfidenceCount)")
            }
        }
        .padding(20)
        .background(themeManager.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(themeManager.isDark ? 0.3 : 0.08), radius: 16, x: 0, y: 8)
    }

    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(themeManager.theme.textPrimary)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(themeManager.theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Bands Section

    private var bandsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(category == .putting ? "PUTTING BANDS" : "DISTANCE BANDS")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundColor(themeManager.theme.textSecondary)

            if category == .putting {
                puttingBandsList
            } else {
                distanceBandsList
            }
        }
    }

    private var puttingBandsList: some View {
        VStack(spacing: 8) {
            ForEach(PuttingBand.allCases, id: \.self) { band in
                if let summary = viewModel.currentSummary,
                   let sg = summary.sgByPuttingBand[band] {
                    bandRow(
                        label: band.rawValue,
                        sg: sg,
                        shots: summary.shotsByPuttingBand[band] ?? 0
                    )
                }
            }

            if viewModel.currentSummary?.sgByPuttingBand.isEmpty ?? true {
                Text("No putting data available")
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.theme.textMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }
        }
    }

    private var distanceBandsList: some View {
        VStack(spacing: 8) {
            ForEach(DistanceBand.allCases, id: \.self) { band in
                if let summary = viewModel.currentSummary,
                   let sg = summary.sgByDistanceBand[band] {
                    bandRow(
                        label: "\(band.rawValue) yards",
                        sg: sg,
                        shots: summary.shotsByDistanceBand[band] ?? 0
                    )
                }
            }

            if viewModel.currentSummary?.sgByDistanceBand.isEmpty ?? true {
                Text("No distance data available")
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.theme.textMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }
        }
    }

    private func bandRow(label: String, sg: Double, shots: Int) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.theme.textPrimary)

            Spacer()

            Text("\(shots) shots")
                .font(.system(size: 12))
                .foregroundColor(themeManager.theme.textMuted)
                .padding(.trailing, 12)

            Text(formatSG(sg))
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(sgColor(for: sg))
                .frame(width: 70, alignment: .trailing)
        }
        .padding(14)
        .background(themeManager.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Top Shots Section

    private var topShotsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("TOP SHOTS")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundColor(themeManager.theme.textSecondary)

            VStack(spacing: 12) {
                // Best shots
                let bestShots = viewModel.bestShots(for: category).prefix(3)
                if !bestShots.isEmpty {
                    ForEach(Array(bestShots)) { shot in
                        shotRow(shot: shot, isBest: true)
                    }
                }

                // Worst shots
                let worstShots = viewModel.worstShots(for: category).prefix(3)
                if !worstShots.isEmpty {
                    Divider()
                        .background(themeManager.theme.border)
                        .padding(.vertical, 4)

                    ForEach(Array(worstShots)) { shot in
                        shotRow(shot: shot, isBest: false)
                    }
                }

                if categoryShots.isEmpty {
                    Text("No shots in this category")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.theme.textMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                }
            }
            .padding(16)
            .background(themeManager.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private func shotRow(shot: ShotRowModel, isBest: Bool) -> some View {
        Button(action: { selectedShot = shot }) {
            HStack(spacing: 12) {
                // Indicator
                Circle()
                    .fill(isBest ? themeManager.theme.accentGreen : themeManager.theme.error)
                    .frame(width: 8, height: 8)

                // Hole & Shot info
                VStack(alignment: .leading, spacing: 2) {
                    Text("Hole \(shot.holeNumber), Shot \(shot.shotIndex)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Text("\(shot.startDistDisplay) → \(shot.endDistDisplay)")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.theme.textSecondary)
                }

                Spacer()

                // SG value
                Text(shot.sgFormatted)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(sgColor(for: shot.strokesGained ?? 0))

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.theme.textMuted)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - All Shots Section

    private var allShotsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("ALL SHOTS")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(themeManager.theme.textSecondary)

                Spacer()

                Text("\(categoryShots.count) total")
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.theme.textMuted)
            }

            ForEach(categoryShots) { shot in
                Button(action: { selectedShot = shot }) {
                    compactShotRow(shot: shot)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private func compactShotRow(shot: ShotRowModel) -> some View {
        HStack(spacing: 12) {
            // Hole badge
            Text("\(shot.holeNumber)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(themeManager.theme.textSecondary)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text("Shot \(shot.shotIndex)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(themeManager.theme.textPrimary)

                HStack(spacing: 4) {
                    Text(shot.startLie.displayName)
                        .font(.system(size: 11))
                        .foregroundColor(themeManager.theme.textSecondary)

                    Text("→")
                        .font(.system(size: 11))
                        .foregroundColor(themeManager.theme.textMuted)

                    Text(shot.isHoled ? "Holed" : shot.endLie.displayName)
                        .font(.system(size: 11))
                        .foregroundColor(themeManager.theme.textSecondary)
                }
            }

            Spacer()

            if shot.needsReview {
                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.theme.error)
            }

            Text(shot.sgFormatted)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(sgColor(for: shot.strokesGained ?? 0))
        }
        .padding(12)
        .background(themeManager.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Computed Properties

    private var categoryShots: [ShotRowModel] {
        viewModel.shots(for: category)
    }

    private var avgSGPerShot: String {
        let shots = categoryShots
        guard !shots.isEmpty else { return "--" }
        let total = shots.compactMap { $0.strokesGained }.reduce(0, +)
        let avg = total / Double(shots.count)
        return formatSG(avg)
    }

    private var highConfidenceCount: Int {
        categoryShots.filter { $0.confidence.isHighConfidence }.count
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

// MARK: - ShotRowModel Identifiable

extension ShotRowModel: Equatable {
    static func == (lhs: ShotRowModel, rhs: ShotRowModel) -> Bool {
        lhs.id == rhs.id
    }
}

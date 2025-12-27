import SwiftUI

// MARK: - Hole Detail View

struct HoleDetailView: View {
    let holeNumber: Int
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel = StrokesGainedViewModel.shared
    @State private var selectedShot: ShotRowModel?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerSection

                // Shot Table
                shotTableSection
            }
            .background(themeManager.theme.background)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Hole \(holeNumber)")
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
            .sheet(item: $selectedShot) { shot in
                ShotDetailEditorView(shot: shot)
                    .environmentObject(themeManager)
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                // Hole badge
                Text("\(holeNumber)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(themeManager.theme.accentGreen)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("Hole \(holeNumber)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Text("\(holeShots.count) shots")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.theme.textSecondary)
                }

                Spacer()

                // Hole SG
                VStack(alignment: .trailing, spacing: 4) {
                    Text("SG")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(themeManager.theme.textMuted)

                    Text(formatSG(holeSG))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(sgColor(for: holeSG))
                }
            }

            // SG Breakdown mini bar
            sgBreakdownBar
        }
        .padding(20)
        .background(themeManager.theme.cardBackground)
    }

    private var sgBreakdownBar: some View {
        HStack(spacing: 8) {
            ForEach(SGCategory.allCases, id: \.self) { category in
                let sg = categorySG(for: category)
                if sg != 0 {
                    HStack(spacing: 4) {
                        Image(systemName: category.icon)
                            .font(.system(size: 10))
                            .foregroundColor(sgColor(for: sg))

                        Text(formatSG(sg))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(sgColor(for: sg))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(sgColor(for: sg).opacity(0.15))
                    .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - Shot Table Section

    private var shotTableSection: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Table Header
                tableHeader

                // Shot Rows
                ForEach(holeShots) { shot in
                    Button(action: { selectedShot = shot }) {
                        shotTableRow(shot: shot)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Divider()
                        .background(themeManager.theme.border.opacity(0.5))
                }

                // Totals Row
                totalsRow
            }
            .background(themeManager.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(20)
        }
    }

    private var tableHeader: some View {
        HStack(spacing: 0) {
            Text("#")
                .frame(width: 30, alignment: .leading)
            Text("Start")
                .frame(width: 60, alignment: .leading)
            Text("Lie")
                .frame(width: 50, alignment: .leading)
            Text("End")
                .frame(width: 60, alignment: .leading)
            Text("Lie")
                .frame(width: 50, alignment: .leading)
            Spacer()
            Text("SG")
                .frame(width: 60, alignment: .trailing)
        }
        .font(.system(size: 10, weight: .bold))
        .foregroundColor(themeManager.theme.textMuted)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(themeManager.theme.backgroundSecondary)
    }

    private func shotTableRow(shot: ShotRowModel) -> some View {
        HStack(spacing: 0) {
            // Shot number
            Text("\(shot.shotIndex)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(themeManager.theme.textPrimary)
                .frame(width: 30, alignment: .leading)

            // Start distance
            Text(shot.startDistDisplay)
                .font(.system(size: 12))
                .foregroundColor(themeManager.theme.textPrimary)
                .frame(width: 60, alignment: .leading)

            // Start lie
            Text(shot.startLie.displayName)
                .font(.system(size: 11))
                .foregroundColor(themeManager.theme.textSecondary)
                .frame(width: 50, alignment: .leading)

            // End distance
            Text(shot.endDistDisplay)
                .font(.system(size: 12))
                .foregroundColor(themeManager.theme.textPrimary)
                .frame(width: 60, alignment: .leading)

            // End lie
            Text(shot.isHoled ? "Holed" : shot.endLie.displayName)
                .font(.system(size: 11))
                .foregroundColor(shot.isHoled ? themeManager.theme.accentGreen : themeManager.theme.textSecondary)
                .frame(width: 50, alignment: .leading)

            Spacer()

            // Penalty indicator
            if shot.penaltyStrokes > 0 {
                Text("+\(shot.penaltyStrokes)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(themeManager.theme.error)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(themeManager.theme.error.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(.trailing, 4)
            }

            // Review indicator
            if shot.needsReview {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.theme.error.opacity(0.8))
                    .padding(.trailing, 4)
            }

            // SG value
            Text(shot.sgFormatted)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(sgColor(for: shot.strokesGained ?? 0))
                .frame(width: 60, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private var totalsRow: some View {
        HStack {
            Text("Total")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(themeManager.theme.textPrimary)

            Spacer()

            Text(formatSG(holeSG))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(sgColor(for: holeSG))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(themeManager.theme.backgroundSecondary)
    }

    // MARK: - Computed Properties

    private var holeShots: [ShotRowModel] {
        viewModel.shots(for: holeNumber)
    }

    private var holeSG: Double {
        viewModel.currentSummary?.sgByHole[holeNumber] ?? 0
    }

    private func categorySG(for category: SGCategory) -> Double {
        let shots = holeShots.filter { shot in
            // Determine category from shot type/lie
            if let sg = shot.strokesGained {
                return viewModel.category(for: shot) == category
            }
            return false
        }
        return shots.compactMap { $0.strokesGained }.reduce(0, +)
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

// MARK: - Shot Detail Editor View

struct ShotDetailEditorView: View {
    let shot: ShotRowModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel = StrokesGainedViewModel.shared

    // Edit state
    @State private var editedStartDistance: String = ""
    @State private var editedEndDistance: String = ""
    @State private var editedStartLie: Lie = .unknown
    @State private var editedEndLie: Lie = .unknown
    @State private var editedPenalty: Int = 0
    @State private var editedHoleNumber: String = ""

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Video Preview Placeholder
                    videoPreviewSection

                    // Shot Info
                    shotInfoCard

                    // Edit Fields
                    editFieldsSection

                    // Confidence & Provenance
                    confidenceSection

                    // Save Button
                    saveButton

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
                    Text("Shot Details")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(themeManager.theme.textSecondary)
                }
            }
            .onAppear { loadShotData() }
        }
    }

    // MARK: - Video Preview

    private var videoPreviewSection: some View {
        VStack(spacing: 12) {
            // Video player placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(themeManager.theme.backgroundSecondary)
                    .frame(height: 200)

                if shot.impactTime != nil {
                    VStack(spacing: 8) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(themeManager.theme.accentGreen)

                        Text("View Shot Video")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.theme.textSecondary)
                    }
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "video.slash")
                            .font(.system(size: 32))
                            .foregroundColor(themeManager.theme.textMuted)

                        Text("No video linked")
                            .font(.system(size: 14))
                            .foregroundColor(themeManager.theme.textMuted)
                    }
                }
            }

            // Scrub bar placeholder
            if shot.impactTime != nil {
                HStack {
                    Text(formatTime(shot.clipStart ?? 0))
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(themeManager.theme.textMuted)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(themeManager.theme.border)
                                .frame(height: 4)

                            // Impact marker
                            if let impact = shot.impactTime, let start = shot.clipStart, let end = shot.clipEnd {
                                let progress = (impact - start) / (end - start)
                                Circle()
                                    .fill(themeManager.theme.accentGreen)
                                    .frame(width: 12, height: 12)
                                    .offset(x: geo.size.width * CGFloat(progress) - 6)
                            }
                        }
                    }
                    .frame(height: 12)

                    Text(formatTime(shot.clipEnd ?? 0))
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(themeManager.theme.textMuted)
                }
            }
        }
    }

    // MARK: - Shot Info Card

    private var shotInfoCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Hole \(shot.holeNumber), Shot \(shot.shotIndex)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(themeManager.theme.textPrimary)

                Spacer()

                Text(shot.sgFormatted)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(sgColor(for: shot.strokesGained ?? 0))
            }

            Divider()
                .background(themeManager.theme.border)

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Start")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(themeManager.theme.textMuted)
                    Text("\(shot.startDistDisplay)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.theme.textPrimary)
                    Text(shot.startLie.displayName)
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.theme.textSecondary)
                }

                Image(systemName: "arrow.right")
                    .font(.system(size: 16))
                    .foregroundColor(themeManager.theme.textMuted)

                VStack(alignment: .leading, spacing: 4) {
                    Text("End")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(themeManager.theme.textMuted)
                    Text("\(shot.endDistDisplay)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.theme.textPrimary)
                    Text(shot.isHoled ? "Holed!" : shot.endLie.displayName)
                        .font(.system(size: 12))
                        .foregroundColor(shot.isHoled ? themeManager.theme.accentGreen : themeManager.theme.textSecondary)
                }

                Spacer()

                if shot.penaltyStrokes > 0 {
                    VStack(spacing: 4) {
                        Text("Penalty")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(themeManager.theme.textMuted)
                        Text("+\(shot.penaltyStrokes)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(themeManager.theme.error)
                    }
                }
            }
        }
        .padding(16)
        .background(themeManager.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Edit Fields

    private var editFieldsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("EDIT SHOT")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundColor(themeManager.theme.textSecondary)

            VStack(spacing: 12) {
                // Hole Number
                editRow(label: "Hole Number", text: $editedHoleNumber, keyboardType: .numberPad)

                Divider().background(themeManager.theme.border)

                // Start Distance
                editRow(label: "Start Distance", text: $editedStartDistance, keyboardType: .decimalPad)

                // Start Lie Picker
                liePicker(label: "Start Lie", selection: $editedStartLie)

                Divider().background(themeManager.theme.border)

                // End Distance
                editRow(label: "End Distance", text: $editedEndDistance, keyboardType: .decimalPad)

                // End Lie Picker
                liePicker(label: "End Lie", selection: $editedEndLie)

                Divider().background(themeManager.theme.border)

                // Penalty Stepper
                HStack {
                    Text("Penalty Strokes")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Spacer()

                    HStack(spacing: 16) {
                        Button(action: { if editedPenalty > 0 { editedPenalty -= 1 } }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(editedPenalty > 0 ? themeManager.theme.accentGreen : themeManager.theme.textMuted)
                        }

                        Text("\(editedPenalty)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(themeManager.theme.textPrimary)
                            .frame(minWidth: 30)

                        Button(action: { editedPenalty += 1 }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(themeManager.theme.accentGreen)
                        }
                    }
                }
            }
            .padding(16)
            .background(themeManager.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private func editRow(label: String, text: Binding<String>, keyboardType: UIKeyboardType) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.theme.textPrimary)

            Spacer()

            TextField("", text: text)
                .font(.system(size: 14))
                .keyboardType(keyboardType)
                .multilineTextAlignment(.trailing)
                .foregroundColor(themeManager.theme.textPrimary)
                .frame(width: 100)
        }
    }

    private func liePicker(label: String, selection: Binding<Lie>) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.theme.textPrimary)

            Spacer()

            Menu {
                ForEach(Lie.allCases, id: \.self) { lie in
                    Button(lie.displayName) {
                        selection.wrappedValue = lie
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(selection.wrappedValue.displayName)
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(themeManager.theme.textMuted)
                }
            }
        }
    }

    // MARK: - Confidence Section

    private var confidenceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CONFIDENCE & PROVENANCE")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundColor(themeManager.theme.textSecondary)

            VStack(spacing: 12) {
                confidenceRow(label: "Overall", value: shot.confidence.overall)
                confidenceRow(label: "Hole", value: shot.confidence.holeConfidence)
                confidenceRow(label: "Start Location", value: shot.confidence.startLocationConfidence)
                confidenceRow(label: "End Location", value: shot.confidence.endLocationConfidence)
                confidenceRow(label: "Lie", value: shot.confidence.lieConfidence)

                if !shot.flags.isEmpty {
                    Divider().background(themeManager.theme.border)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Flags")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(themeManager.theme.textSecondary)

                        ForEach(shot.flags, id: \.self) { flag in
                            HStack(spacing: 6) {
                                Image(systemName: "flag.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(themeManager.theme.error)
                                Text(flag.replacingOccurrences(of: "_", with: " "))
                                    .font(.system(size: 12))
                                    .foregroundColor(themeManager.theme.textPrimary)
                            }
                        }
                    }
                }
            }
            .padding(16)
            .background(themeManager.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private func confidenceRow(label: String, value: Double) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(themeManager.theme.textSecondary)

            Spacer()

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(themeManager.theme.border)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(confidenceColor(value))
                        .frame(width: geo.size.width * CGFloat(value), height: 6)
                }
            }
            .frame(width: 60, height: 6)

            Text("\(Int(value * 100))%")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(confidenceColor(value))
                .frame(width: 40, alignment: .trailing)
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button(action: saveChanges) {
            Text("Save Changes")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(themeManager.theme.accentGreen)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    // MARK: - Actions

    private func loadShotData() {
        editedHoleNumber = "\(shot.holeNumber)"
        editedStartDistance = shot.startDistDisplay.replacingOccurrences(of: " yds", with: "").replacingOccurrences(of: " ft", with: "")
        editedEndDistance = shot.endDistDisplay.replacingOccurrences(of: " yds", with: "").replacingOccurrences(of: " ft", with: "").replacingOccurrences(of: "Holed", with: "0")
        editedStartLie = shot.startLie
        editedEndLie = shot.endLie
        editedPenalty = shot.penaltyStrokes
    }

    private func saveChanges() {
        // TODO: Update viewModel with changes
        dismiss()
    }

    // MARK: - Helpers

    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
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

    private func confidenceColor(_ value: Double) -> Color {
        if value >= 0.7 {
            return themeManager.theme.accentGreen
        } else if value >= 0.5 {
            return .orange
        } else {
            return themeManager.theme.error
        }
    }
}

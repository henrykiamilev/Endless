import SwiftUI
import Combine

// MARK: - Drills Manager

class DrillsManager: ObservableObject {
    static let shared = DrillsManager()

    @Published var drills: [Drill] {
        didSet { saveDrills() }
    }

    @Published var lastRefreshDate: Date {
        didSet {
            UserDefaults.standard.set(lastRefreshDate.timeIntervalSince1970, forKey: "drillsLastRefresh")
        }
    }

    private init() {
        let savedDate = UserDefaults.standard.double(forKey: "drillsLastRefresh")
        self.lastRefreshDate = savedDate > 0 ? Date(timeIntervalSince1970: savedDate) : Date()
        self.drills = Self.loadDrills()
        checkForNewDay()
    }

    var completedCount: Int {
        drills.filter { $0.isCompleted }.count
    }

    var totalDuration: String {
        let totalMinutes = drills.reduce(0) { sum, drill in
            let minutes = Int(drill.duration.replacingOccurrences(of: " min", with: "")) ?? 0
            return sum + minutes
        }
        return "\(totalMinutes) min"
    }

    func toggleDrill(_ id: String) {
        if let index = drills.firstIndex(where: { $0.id == id }) {
            drills[index].isCompleted.toggle()
        }
    }

    private func checkForNewDay() {
        let calendar = Calendar.current
        if !calendar.isDateInToday(lastRefreshDate) {
            // Reset drills for new day
            drills = MockData.todaysDrills.shuffled()
            lastRefreshDate = Date()
        }
    }

    private func saveDrills() {
        // In a real app, save to UserDefaults or database
    }

    private static func loadDrills() -> [Drill] {
        // In a real app, load from UserDefaults or database
        return MockData.todaysDrills
    }
}

// MARK: - Today's Drills View

struct TodaysDrillsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject private var drillsManager = DrillsManager.shared

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header card
                    headerCard

                    // Progress section
                    progressSection

                    // Drills list
                    drillsList
                }
                .padding(20)
            }
            .background(themeManager.theme.background)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
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

    // MARK: - Header Card

    private var headerCard: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(themeManager.theme.accentGreen.opacity(0.15))
                    .frame(width: 72, height: 72)

                Image(systemName: "figure.golf")
                    .font(.system(size: 32))
                    .foregroundColor(themeManager.theme.accentGreen)
            }

            // Title
            Text("Today's Drills")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(themeManager.theme.textPrimary)

            // Date
            Text(dateFormatter.string(from: Date()))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.theme.textSecondary)

            // Description
            Text("Complete these drills to improve your game. New drills are generated each day based on your performance.")
                .font(.system(size: 14))
                .foregroundColor(themeManager.theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(themeManager.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    // MARK: - Progress Section

    private var progressSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Progress")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(themeManager.theme.textPrimary)

                Spacer()

                Text("\(drillsManager.completedCount)/\(drillsManager.drills.count) completed")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.theme.textSecondary)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(themeManager.theme.cardBackground)
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(themeManager.theme.accentGreen)
                        .frame(
                            width: geometry.size.width * CGFloat(drillsManager.completedCount) / CGFloat(max(drillsManager.drills.count, 1)),
                            height: 12
                        )
                        .animation(.spring(response: 0.4), value: drillsManager.completedCount)
                }
            }
            .frame(height: 12)

            // Stats row
            HStack(spacing: 0) {
                statItem(label: "Total Time", value: drillsManager.totalDuration, icon: "clock")
                statItem(label: "Categories", value: "\(Set(drillsManager.drills.map { $0.category }).count)", icon: "square.grid.2x2")
                statItem(label: "Remaining", value: "\(drillsManager.drills.count - drillsManager.completedCount)", icon: "checklist")
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(themeManager.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func statItem(label: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(themeManager.theme.textSecondary)

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(themeManager.theme.textPrimary)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(themeManager.theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Drills List

    private var drillsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Drills")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(themeManager.theme.textPrimary)

            VStack(spacing: 12) {
                ForEach(drillsManager.drills) { drill in
                    DrillCard(drill: drill) {
                        withAnimation(.spring(response: 0.3)) {
                            drillsManager.toggleDrill(drill.id)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Drill Card

struct DrillCard: View {
    let drill: Drill
    let onToggle: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isExpanded = false

    var categoryIcon: String {
        switch drill.category {
        case .putting: return "circle.fill"
        case .driving: return "arrow.up.right"
        case .shortGame: return "flag.fill"
        case .irons: return "figure.golf"
        case .mental: return "brain.head.profile"
        }
    }

    var categoryColor: Color {
        switch drill.category {
        case .putting: return Color(hex: "22C55E")
        case .driving: return Color(hex: "3B82F6")
        case .shortGame: return Color(hex: "F59E0B")
        case .irons: return Color(hex: "8B5CF6")
        case .mental: return Color(hex: "EC4899")
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Main row
            HStack(spacing: 14) {
                // Checkbox
                Button(action: onToggle) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(drill.isCompleted ? themeManager.theme.accentGreen : themeManager.theme.border, lineWidth: 2)
                            .frame(width: 28, height: 28)

                        if drill.isCompleted {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(themeManager.theme.accentGreen)
                                .frame(width: 28, height: 28)

                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }

                // Icon
                ZStack {
                    Circle()
                        .fill(categoryColor.opacity(0.15))
                        .frame(width: 40, height: 40)

                    Image(systemName: categoryIcon)
                        .font(.system(size: 16))
                        .foregroundColor(categoryColor)
                }

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(drill.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(drill.isCompleted ? themeManager.theme.textSecondary : themeManager.theme.textPrimary)
                        .strikethrough(drill.isCompleted)

                    HStack(spacing: 8) {
                        Text(drill.category.rawValue)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(categoryColor)

                        Text("•")
                            .foregroundColor(themeManager.theme.textMuted)

                        Text(drill.duration)
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.theme.textSecondary)
                    }
                }

                Spacer()

                // Expand button
                Button(action: { withAnimation(.spring(response: 0.3)) { isExpanded.toggle() } }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.theme.textSecondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
            }
            .padding(16)

            // Expanded description
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .background(themeManager.theme.border.opacity(0.5))

                    Text(drill.description)
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.theme.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                }
            }
        }
        .background(themeManager.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .opacity(drill.isCompleted ? 0.7 : 1.0)
    }
}

#Preview {
    TodaysDrillsView()
        .environmentObject(ThemeManager())
}

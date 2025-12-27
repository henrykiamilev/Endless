import SwiftUI
import Combine
// MARK: - Performance Widget Model

struct PerformanceWidget: Identifiable, Codable, Equatable {
    let id: String
    let icon: String
    let label: String
    let shortLabel: String
    var value: String
    var color: String  // Hex color for accent
    var isEnabled: Bool
    var size: WidgetSize

    enum WidgetSize: String, Codable {
        case small   // 1x1 square
        case medium  // 2x1 rectangle
        case large   // 2x2 square
    }

    static let allWidgets: [PerformanceWidget] = [
        PerformanceWidget(id: "sg_total", icon: "chart.line.uptrend.xyaxis", label: "Strokes Gained", shortLabel: "SG", value: "--", color: "22C55E", isEnabled: true, size: .medium),
        PerformanceWidget(id: "gir", icon: "figure.golf", label: "Greens in Regulation", shortLabel: "GIR", value: "--", color: "22C55E", isEnabled: true, size: .medium),
        PerformanceWidget(id: "fir", icon: "flag.fill", label: "Fairways in Regulation", shortLabel: "FIR", value: "--", color: "22C55E", isEnabled: true, size: .small),
        PerformanceWidget(id: "putts", icon: "circle.fill", label: "Putts per Round", shortLabel: "Putts", value: "--", color: "22C55E", isEnabled: true, size: .small),
        PerformanceWidget(id: "avg", icon: "trophy.fill", label: "Scoring Average", shortLabel: "Avg", value: "--", color: "22C55E", isEnabled: false, size: .medium),
        PerformanceWidget(id: "sg_ott", icon: "figure.golf", label: "SG: Off the Tee", shortLabel: "OTT", value: "--", color: "22C55E", isEnabled: false, size: .small),
        PerformanceWidget(id: "sg_app", icon: "arrow.up.right", label: "SG: Approach", shortLabel: "APP", value: "--", color: "22C55E", isEnabled: false, size: .small),
        PerformanceWidget(id: "sg_arg", icon: "flag.fill", label: "SG: Short Game", shortLabel: "ARG", value: "--", color: "22C55E", isEnabled: false, size: .small),
        PerformanceWidget(id: "sg_putt", icon: "circle.fill", label: "SG: Putting", shortLabel: "PUTT", value: "--", color: "22C55E", isEnabled: false, size: .small),
        PerformanceWidget(id: "handicap", icon: "chart.bar.fill", label: "Handicap Index", shortLabel: "HCP", value: "--", color: "22C55E", isEnabled: false, size: .small),
        PerformanceWidget(id: "driving", icon: "arrow.up.right", label: "Driving Distance", shortLabel: "Drive", value: "--", color: "22C55E", isEnabled: false, size: .medium),
        PerformanceWidget(id: "scramble", icon: "arrow.triangle.2.circlepath", label: "Scrambling %", shortLabel: "Scr", value: "--", color: "22C55E", isEnabled: false, size: .small),
        PerformanceWidget(id: "sandsave", icon: "leaf.fill", label: "Sand Save %", shortLabel: "Sand", value: "--", color: "22C55E", isEnabled: false, size: .small),
        PerformanceWidget(id: "updown", icon: "arrow.up.arrow.down", label: "Up & Down %", shortLabel: "U&D", value: "--", color: "22C55E", isEnabled: false, size: .small),
        PerformanceWidget(id: "rounds", icon: "repeat", label: "Rounds Played", shortLabel: "Rnds", value: "0", color: "22C55E", isEnabled: false, size: .small)
    ]
}

// MARK: - Shared Widget Manager (Singleton for persistence)

class WidgetPreferencesManager: ObservableObject {
    static let shared = WidgetPreferencesManager()

    @Published var widgets: [PerformanceWidget] {
        didSet {
            saveWidgets()
            objectWillChange.send()
        }
    }

    /// The current user's ID - widget preferences are stored per-user
    private var currentUserId: String?

    /// User-specific key for widget preferences storage
    private var widgetsKey: String {
        if let userId = currentUserId {
            return "performanceWidgets_\(userId)"
        }
        return "performanceWidgets"
    }

    private init() {
        // Initialize with defaults - data will be loaded when user is set
        self.widgets = PerformanceWidget.allWidgets
    }

    // MARK: - User Context Management

    /// Sets the current user and loads their widget preferences
    /// Call this when a user signs in
    func setCurrentUser(userId: String) {
        guard currentUserId != userId else { return }

        currentUserId = userId
        widgets = loadWidgets()
    }

    /// Clears the current user context without deleting data
    /// Call this when a user signs out
    func clearCurrentUser() {
        currentUserId = nil
        widgets = PerformanceWidget.allWidgets
    }

    var enabledWidgets: [PerformanceWidget] {
        widgets.filter { $0.isEnabled }
    }

    func toggleWidget(_ id: String) {
        if let index = widgets.firstIndex(where: { $0.id == id }) {
            widgets[index].isEnabled.toggle()
        }
    }

    func updateValue(for id: String, value: String) {
        if let index = widgets.firstIndex(where: { $0.id == id }) {
            widgets[index].value = value
        }
    }

    func updateSize(for id: String, size: PerformanceWidget.WidgetSize) {
        if let index = widgets.firstIndex(where: { $0.id == id }) {
            widgets[index].size = size
        }
    }

    private func saveWidgets() {
        guard currentUserId != nil else { return }
        if let encoded = try? JSONEncoder().encode(widgets) {
            UserDefaults.standard.set(encoded, forKey: widgetsKey)
        }
    }

    private func loadWidgets() -> [PerformanceWidget] {
        if let data = UserDefaults.standard.data(forKey: widgetsKey),
           let decoded = try? JSONDecoder().decode([PerformanceWidget].self, from: data) {
            return decoded
        }
        return PerformanceWidget.allWidgets
    }

    /// Permanently deletes the user's widget preferences
    /// WARNING: This permanently deletes data. Use clearCurrentUser() for sign-out instead.
    func resetToDefaults() {
        UserDefaults.standard.removeObject(forKey: widgetsKey)
        widgets = PerformanceWidget.allWidgets
    }
}

// MARK: - iOS Style Performance Widgets View

struct PerformanceSnapshot: View {
    var onTap: (() -> Void)?
    var onCustomize: (() -> Void)?
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject private var widgetManager = WidgetPreferencesManager.shared

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(themeManager.theme.accentGreen.opacity(0.6))
                        .frame(width: 6, height: 6)
                    Text("Performance")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)
                }

                Spacer()

                // Customize button (+ icon)
                Button(action: { onCustomize?() }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(themeManager.theme.textSecondary.opacity(0.6))
                }
            }

            // iOS-style widget grid
            widgetGrid
        }
    }

    private var widgetGrid: some View {
        let enabled = widgetManager.enabledWidgets

        return Group {
            if enabled.isEmpty {
                emptyStateView
            } else {
                // All widgets in a single horizontal row
                HStack(spacing: 8) {
                    ForEach(enabled.prefix(4)) { widget in
                        WidgetCard(widget: widget, onTap: onTap)
                    }
                }
            }
        }
    }

    private var emptyStateView: some View {
        Button(action: { onCustomize?() }) {
            VStack(spacing: 12) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 28))
                    .foregroundColor(themeManager.theme.textSecondary.opacity(0.5))

                Text("Add Widgets")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.theme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(themeManager.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(themeManager.theme.border.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Widget Card (iOS Style)

struct WidgetCard: View {
    let widget: PerformanceWidget
    var onTap: (() -> Void)?
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(spacing: 8) {
                // Centered icon
                Image(systemName: widget.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(themeManager.theme.accentGreen)

                // Centered value
                Text(widget.value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(themeManager.theme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(themeManager.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Widget Customization Sheet (iOS Style)

struct WidgetCustomizationSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject private var widgetManager = WidgetPreferencesManager.shared
    @State private var editingWidget: PerformanceWidget?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 32))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Text("Edit Widgets")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Text("\(widgetManager.enabledWidgets.count) of 4 selected")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.theme.textSecondary)
                }
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                .background(themeManager.theme.cardBackground)

                // Widget grid
                ScrollView {
                    let enabledCount = widgetManager.enabledWidgets.count
                    let canAddMore = enabledCount < 4

                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        ForEach(widgetManager.widgets) { widget in
                            WidgetSelectionCard(
                                widget: widget,
                                isSelected: widget.isEnabled,
                                canAdd: canAddMore,
                                onToggle: {
                                    withAnimation(.spring(response: 0.3)) {
                                        widgetManager.toggleWidget(widget.id)
                                    }
                                },
                                onEdit: {
                                    editingWidget = widget
                                }
                            )
                        }
                    }
                    .padding(20)
                }

                // Done button
                Button(action: { dismiss() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                        Text("Done")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(themeManager.theme.textPrimary)
                    .clipShape(Capsule())
                }
                .padding(20)
                .background(themeManager.theme.background)
            }
            .background(themeManager.theme.background)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
            .sheet(item: $editingWidget) { widget in
                EditWidgetValueSheet(widget: widget, widgetManager: widgetManager)
            }
        }
    }
}

// MARK: - Widget Selection Card

struct WidgetSelectionCard: View {
    let widget: PerformanceWidget
    let isSelected: Bool
    let canAdd: Bool
    let onToggle: () -> Void
    let onEdit: () -> Void
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 12) {
            // Widget preview
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(themeManager.theme.textSecondary.opacity(isSelected ? 0.12 : 0.06))
                            .frame(width: 32, height: 32)

                        Image(systemName: widget.icon)
                            .font(.system(size: 14))
                            .foregroundColor(isSelected ? themeManager.theme.textPrimary : themeManager.theme.textMuted)
                    }

                    Spacer()

                    // Edit button
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(themeManager.theme.textMuted)
                            .frame(width: 24, height: 24)
                            .background(themeManager.theme.backgroundSecondary)
                            .clipShape(Circle())
                    }
                }

                Text(widget.value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(isSelected ? themeManager.theme.textPrimary : themeManager.theme.textMuted)

                Text(widget.label)
                    .font(.system(size: 11))
                    .foregroundColor(themeManager.theme.textSecondary)
                    .lineLimit(1)
            }
            .padding(14)
            .background(themeManager.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? themeManager.theme.textPrimary.opacity(0.3) : themeManager.theme.border, lineWidth: isSelected ? 1.5 : 1)
            )

            // Toggle button
            Button(action: {
                // Only allow toggle if removing or if we can add
                if isSelected || canAdd {
                    onToggle()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle")
                        .font(.system(size: 14))
                    Text(isSelected ? "Added" : "Add")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(isSelected ? themeManager.theme.textPrimary : (canAdd ? themeManager.theme.textSecondary : themeManager.theme.textMuted.opacity(0.5)))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? themeManager.theme.textPrimary.opacity(0.08) : themeManager.theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .disabled(!isSelected && !canAdd)
        }
    }
}

// MARK: - Edit Widget Value Sheet

struct EditWidgetValueSheet: View {
    let widget: PerformanceWidget
    @ObservedObject var widgetManager: WidgetPreferencesManager
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var newValue: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Widget preview
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(themeManager.theme.textSecondary.opacity(0.1))
                            .frame(width: 72, height: 72)

                        Image(systemName: widget.icon)
                            .font(.system(size: 32))
                            .foregroundColor(themeManager.theme.textPrimary)
                    }

                    Text(widget.label)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)
                }
                .padding(.top, 24)

                // Value input
                VStack(alignment: .leading, spacing: 8) {
                    Text("VALUE")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1)
                        .foregroundColor(themeManager.theme.textMuted)

                    TextField("Enter value", text: $newValue)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(20)
                        .background(themeManager.theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(themeManager.theme.border, lineWidth: 1)
                        )
                }
                .padding(.horizontal, 20)

                Spacer()

                // Save button
                Button(action: {
                    if !newValue.isEmpty {
                        widgetManager.updateValue(for: widget.id, value: newValue)
                    }
                    dismiss()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                        Text("Save")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(themeManager.theme.textPrimary)
                    .clipShape(Capsule())
                }
                .padding(20)
            }
            .background(themeManager.theme.background)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
        .onAppear {
            newValue = widget.value
        }
    }
}

#Preview {
    PerformanceSnapshot()
        .environmentObject(ThemeManager())
        .padding()
}

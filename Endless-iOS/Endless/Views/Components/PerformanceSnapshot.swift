import SwiftUI

// MARK: - Performance Widget Model

struct PerformanceWidget: Identifiable, Codable, Equatable {
    let id: String
    let icon: String
    let label: String
    let shortLabel: String
    var value: String
    var color: String  // Hex color for accent
    var isEnabled: Bool

    static let allWidgets: [PerformanceWidget] = [
        PerformanceWidget(id: "gir", icon: "figure.golf", label: "Greens in Regulation", shortLabel: "GIR", value: "72%", color: "60A5FA", isEnabled: true),
        PerformanceWidget(id: "fir", icon: "flag.fill", label: "Fairways in Regulation", shortLabel: "FIR", value: "65%", color: "4ADE80", isEnabled: true),
        PerformanceWidget(id: "putts", icon: "circle.fill", label: "Putts per Round", shortLabel: "Putts", value: "28.4", color: "FCD34D", isEnabled: true),
        PerformanceWidget(id: "avg", icon: "trophy.fill", label: "Scoring Average", shortLabel: "Avg", value: "71.3", color: "F87171", isEnabled: true),
        PerformanceWidget(id: "handicap", icon: "chart.line.uptrend.xyaxis", label: "Handicap Index", shortLabel: "HCP", value: "4.2", color: "A78BFA", isEnabled: false),
        PerformanceWidget(id: "driving", icon: "arrow.up.right", label: "Driving Distance", shortLabel: "Drive", value: "275", color: "FB923C", isEnabled: false),
        PerformanceWidget(id: "scramble", icon: "arrow.triangle.2.circlepath", label: "Scrambling %", shortLabel: "Scr", value: "58%", color: "2DD4BF", isEnabled: false),
        PerformanceWidget(id: "sandsave", icon: "leaf.fill", label: "Sand Save %", shortLabel: "Sand", value: "45%", color: "A3E635", isEnabled: false),
        PerformanceWidget(id: "updown", icon: "arrow.up.arrow.down", label: "Up & Down %", shortLabel: "U&D", value: "62%", color: "F472B6", isEnabled: false),
        PerformanceWidget(id: "rounds", icon: "repeat", label: "Rounds Played", shortLabel: "Rnds", value: "18", color: "818CF8", isEnabled: false)
    ]
}

// MARK: - Widget Preferences Manager

class WidgetPreferencesManager: ObservableObject {
    @Published var widgets: [PerformanceWidget] {
        didSet {
            saveWidgets()
        }
    }

    init() {
        self.widgets = Self.loadWidgets()
    }

    var enabledWidgets: [PerformanceWidget] {
        widgets.filter { $0.isEnabled }.prefix(4).map { $0 }
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

    private func saveWidgets() {
        if let encoded = try? JSONEncoder().encode(widgets) {
            UserDefaults.standard.set(encoded, forKey: "performanceWidgets")
        }
    }

    private static func loadWidgets() -> [PerformanceWidget] {
        if let data = UserDefaults.standard.data(forKey: "performanceWidgets"),
           let decoded = try? JSONDecoder().decode([PerformanceWidget].self, from: data) {
            return decoded
        }
        return PerformanceWidget.allWidgets
    }

    func resetToDefaults() {
        widgets = PerformanceWidget.allWidgets
    }
}

// MARK: - Performance Snapshot View

struct PerformanceSnapshot: View {
    var onTap: (() -> Void)?
    var onCustomize: (() -> Void)?
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var widgetManager = WidgetPreferencesManager()

    var body: some View {
        VStack(spacing: 22) {
            // Header
            HStack {
                Text("Performance Snapshot")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(themeManager.theme.textPrimary)

                Spacer()

                // Customize button (+ icon)
                Button(action: { onCustomize?() }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .frame(width: 32, height: 32)
                        .background(themeManager.theme.backgroundSecondary)
                        .clipShape(Circle())
                }
            }

            // Stats row - tappable to go to stats
            Button(action: { onTap?() }) {
                HStack(spacing: 0) {
                    ForEach(widgetManager.enabledWidgets) { widget in
                        StatItem(
                            icon: widget.icon,
                            value: widget.value,
                            label: widget.shortLabel,
                            color: Color(hex: widget.color)
                        )
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(22)
        .background(themeManager.theme.cardBackground)
        .cornerRadius(24)
    }
}

// MARK: - Stat Item

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 10) {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                )

            Text(value)
                .font(.system(size: 22, weight: .heavy))
                .foregroundColor(themeManager.theme.textPrimary)

            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(themeManager.theme.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Widget Customization Sheet

struct WidgetCustomizationSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var widgetManager = WidgetPreferencesManager()
    @State private var editingWidget: PerformanceWidget?
    @State private var editValue: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Text("Customize Widgets")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)

                    Text("Select up to 4 metrics to display")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.theme.textSecondary)
                }
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                .background(themeManager.theme.cardBackground)

                // Active widgets preview
                VStack(alignment: .leading, spacing: 12) {
                    Text("ACTIVE WIDGETS")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1)
                        .foregroundColor(themeManager.theme.textMuted)

                    HStack(spacing: 8) {
                        ForEach(widgetManager.enabledWidgets) { widget in
                            VStack(spacing: 6) {
                                Circle()
                                    .fill(Color(hex: widget.color).opacity(0.15))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Image(systemName: widget.icon)
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(hex: widget.color))
                                    )
                                Text(widget.shortLabel)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(themeManager.theme.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                        }

                        // Empty slots
                        ForEach(0..<(4 - widgetManager.enabledWidgets.count), id: \.self) { _ in
                            VStack(spacing: 6) {
                                Circle()
                                    .stroke(themeManager.theme.border, style: StrokeStyle(lineWidth: 2, dash: [4]))
                                    .frame(width: 36, height: 36)
                                Text("Empty")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(themeManager.theme.textMuted)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(16)
                    .background(themeManager.theme.backgroundSecondary)
                    .cornerRadius(16)
                }
                .padding(20)

                // Widget list
                List {
                    Section {
                        ForEach(widgetManager.widgets) { widget in
                            widgetRow(widget)
                        }
                    } header: {
                        Text("Available Metrics")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1)
                    }
                }
                .listStyle(.insetGrouped)

                // Done button
                Button(action: { dismiss() }) {
                    Text("Done")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(themeManager.theme.textInverse)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(themeManager.theme.textPrimary)
                        .cornerRadius(28)
                }
                .padding(20)
                .background(themeManager.theme.background)
            }
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

    private func widgetRow(_ widget: PerformanceWidget) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Color(hex: widget.color).opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: widget.icon)
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: widget.color))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(widget.label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(themeManager.theme.textPrimary)

                Text("Current: \(widget.value)")
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.theme.textSecondary)
            }

            Spacer()

            // Edit value button
            Button(action: { editingWidget = widget }) {
                Image(systemName: "pencil")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(themeManager.theme.textMuted)
                    .frame(width: 28, height: 28)
                    .background(themeManager.theme.backgroundSecondary)
                    .clipShape(Circle())
            }

            // Toggle
            Toggle("", isOn: Binding(
                get: { widget.isEnabled },
                set: { _ in
                    let enabledCount = widgetManager.widgets.filter { $0.isEnabled }.count
                    if widget.isEnabled || enabledCount < 4 {
                        widgetManager.toggleWidget(widget.id)
                    }
                }
            ))
            .labelsHidden()
            .tint(Color(hex: widget.color))
        }
        .padding(.vertical, 4)
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
                    Circle()
                        .fill(Color(hex: widget.color).opacity(0.15))
                        .frame(width: 64, height: 64)
                        .overlay(
                            Image(systemName: widget.icon)
                                .font(.system(size: 28))
                                .foregroundColor(Color(hex: widget.color))
                        )

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
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(themeManager.theme.textPrimary)
                        .padding(16)
                        .background(themeManager.theme.cardBackground)
                        .cornerRadius(16)
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
                    Text("Save")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(themeManager.theme.textInverse)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(themeManager.theme.textPrimary)
                        .cornerRadius(28)
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

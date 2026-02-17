import SwiftUI

struct ToggleButton: View {
    let options: [String]
    @Binding var selectedIndex: Int
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                Text(option)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(selectedIndex == index ?
                        themeManager.theme.textPrimary :
                        themeManager.theme.textMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        selectedIndex == index ?
                        themeManager.theme.cardBackground :
                        Color.clear
                    )
                    .clipShape(Capsule())
                    .shadow(color: selectedIndex == index ? .black.opacity(themeManager.isDark ? 0.2 : 0.06) : .clear, radius: 4, x: 0, y: 2)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedIndex = index
                        }
                    }
            }
        }
        .padding(3)
        .background(themeManager.theme.backgroundSecondary)
        .clipShape(Capsule())
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selected = 0
        var body: some View {
            ToggleButton(options: ["Video", "Stats"], selectedIndex: $selected)
                .environmentObject(ThemeManager())
                .padding()
        }
    }
    return PreviewWrapper()
}

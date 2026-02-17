import SwiftUI

struct ToggleButton: View {
    let options: [String]
    @Binding var selectedIndex: Int
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                Text(option)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(selectedIndex == index ?
                        .white :
                        themeManager.theme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedIndex == index ?
                        themeManager.theme.accentGreen :
                        Color.clear
                    )
                    .cornerRadius(12)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedIndex = index
                        }
                    }
            }
        }
        .padding(4)
        .background(themeManager.theme.cardBackground)
        .cornerRadius(14)
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

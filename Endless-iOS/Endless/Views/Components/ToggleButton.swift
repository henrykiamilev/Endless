import SwiftUI

struct ToggleButton: View {
    let options: [String]
    @Binding var selectedIndex: Int
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedIndex = index
                    }
                }) {
                    Text(option.uppercased())
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(selectedIndex == index ?
                            themeManager.theme.textInverse :
                            themeManager.theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedIndex == index ?
                            themeManager.theme.textPrimary :
                            Color.clear
                        )
                        .cornerRadius(26)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .background(themeManager.theme.cardBackground)
        .cornerRadius(30)
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

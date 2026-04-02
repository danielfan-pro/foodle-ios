import SwiftUI

struct GlassBackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        LinearGradient(
            colors: gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .background(baseColor)
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(.white.opacity(colorScheme == .dark ? 0.14 : 0.10))
                .frame(width: 260, height: 260)
                .blur(radius: 24)
                .offset(x: 80, y: -60)
        }
        .overlay(alignment: .bottomLeading) {
            Circle()
                .fill((colorScheme == .dark ? Color.cyan : Color.blue).opacity(colorScheme == .dark ? 0.15 : 0.12))
                .frame(width: 220, height: 220)
                .blur(radius: 24)
                .offset(x: -40, y: 80)
        }
        .ignoresSafeArea()
    }

    private var baseColor: Color {
        colorScheme == .dark
            ? Color(red: 0.08, green: 0.10, blue: 0.14)
            : Color(red: 0.76, green: 0.84, blue: 0.96)
    }

    private var gradientColors: [Color] {
        if colorScheme == .dark {
            return [Color(red: 0.12, green: 0.17, blue: 0.25), Color(red: 0.21, green: 0.27, blue: 0.36)]
        } else {
            return [Color(red: 0.54, green: 0.66, blue: 0.82), Color(red: 0.38, green: 0.50, blue: 0.68)]
        }
    }
}

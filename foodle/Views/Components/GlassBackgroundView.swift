import SwiftUI

struct GlassBackgroundView: View {
    var body: some View {
        LinearGradient(
            colors: [Color(red: 0.12, green: 0.17, blue: 0.25), Color(red: 0.21, green: 0.27, blue: 0.36)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(.white.opacity(0.14))
                .frame(width: 260, height: 260)
                .blur(radius: 24)
                .offset(x: 80, y: -60)
        }
        .overlay(alignment: .bottomLeading) {
            Circle()
                .fill(.cyan.opacity(0.15))
                .frame(width: 220, height: 220)
                .blur(radius: 24)
                .offset(x: -40, y: 80)
        }
        .ignoresSafeArea()
    }
}

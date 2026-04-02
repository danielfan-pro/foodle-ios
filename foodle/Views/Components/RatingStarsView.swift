import SwiftUI

struct RatingStarsView: View {
    let rating: Double?

    private var safeRating: Double {
        guard let rating else { return 0 }
        return min(max(rating, 0), 5)
    }

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<5, id: \.self) { index in
                let starIndex = Double(index + 1)
                if safeRating >= starIndex {
                    Image(systemName: "star.fill")
                } else if safeRating + 0.5 >= starIndex {
                    Image(systemName: "star.leadinghalf.filled")
                } else {
                    Image(systemName: "star")
                }
            }
        }
        .foregroundStyle(Color.orange)
        .font(.footnote)
    }
}

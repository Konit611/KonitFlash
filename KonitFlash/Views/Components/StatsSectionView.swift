import SwiftUI

struct StatsSectionView: View {
    var body: some View {
        HStack(spacing: 5) {
            // MARK: - Streak Card (left, narrow)
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.orange)
                        .padding(5)
                        .background(Color.white.opacity(0.5), in: Circle())
                    Spacer()
                }
                .padding(.bottom, 12)

                Text("12")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.black)
                Text("STREAK")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color(hex: 0x7C6172))
                    .tracking(1)
                    .padding(.top, 2)

                Spacer()

                Text("Keep it up !")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.deckBadge, in: RoundedRectangle(cornerRadius: 6))
            }
            .padding(14)
            .frame(maxHeight: .infinity)
            .background(Color.streakPink, in: RoundedRectangle(cornerRadius: 18))
            .frame(width: 119)

            // MARK: - Learned & Reviews Card (right, wider)
            VStack(alignment: .leading, spacing: 10) {
                Text("Let's crush more cards.")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black)

                HStack(spacing: 5) {
                    // Learned sub-card
                    VStack(spacing: 6) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.black.opacity(0.6))
                        Text("342")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.black)
                        Text("LEARNED")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color(hex: 0x7C6172))
                            .tracking(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.reviewsGreen, in: RoundedRectangle(cornerRadius: 18))

                    // Reviews sub-card
                    VStack(spacing: 6) {
                        Image(systemName: "square.3.layers.3d")
                            .font(.system(size: 16))
                            .foregroundStyle(.black.opacity(0.6))
                        Text("1245")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.black)
                        Text("REVIEWS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color(hex: 0x7C6172))
                            .tracking(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.reviewsGreen, in: RoundedRectangle(cornerRadius: 18))
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.learnedGreen, in: RoundedRectangle(cornerRadius: 18))
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    StatsSectionView()
        .padding()
        .background(Color.appBackground)
}

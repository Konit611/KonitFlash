import SwiftUI

struct StatsSectionView: View {
    let stats: StatsViewData
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }

    private var streakRatio: CGFloat {
        isRegular ? 0.3 : 0.31
    }

    var body: some View {
        GeometryReader { geo in
            let streakWidth = geo.size.width * streakRatio
            HStack(spacing: isRegular ? 16 : 5) {
                streakCard
                    .frame(width: streakWidth)
                learnedReviewsCard
                    .frame(maxWidth: .infinity)
            }
        }
        .aspectRatio(isRegular ? 5.5 : 2.15, contentMode: .fit)
    }

    private var streakCard: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: isRegular ? 28 : 20))
                    .foregroundStyle(.orange)
                    .padding(isRegular ? 8 : 5)
                    .background(Color.white.opacity(0.5), in: Circle())
                Spacer()
            }
            .padding(.bottom, isRegular ? 16 : 12)

            Text(stats.streakText)
                .font(.system(size: isRegular ? 48 : 36, weight: .bold))
                .foregroundStyle(.black)
            Text("STREAK")
                .font(.system(size: isRegular ? 16 : 14, weight: .bold))
                .foregroundStyle(Color(hex: 0x7C6172))
                .tracking(1)
                .padding(.top, 2)

            Spacer()

            Text(stats.streakMessage)
                .font(.system(size: isRegular ? 14 : 11, weight: .bold))
                .foregroundStyle(.black)
                .padding(.horizontal, isRegular ? 16 : 12)
                .padding(.vertical, isRegular ? 6 : 4)
                .background(Color.deckBadge, in: RoundedRectangle(cornerRadius: 6))
        }
        .padding(isRegular ? 20 : 14)
        .frame(maxHeight: .infinity)
        .background(Color.streakPink, in: RoundedRectangle(cornerRadius: isRegular ? 20 : 18))
    }

    private var learnedReviewsCard: some View {
        VStack(alignment: .leading, spacing: isRegular ? 14 : 10) {
            Text("Let's crush more cards.")
                .font(.system(size: isRegular ? 16 : 14, weight: .bold))
                .foregroundStyle(.black)

            HStack(spacing: isRegular ? 12 : 5) {
                VStack(spacing: isRegular ? 6 : 6) {
                    Image(systemName: "book.fill")
                        .font(.system(size: isRegular ? 16 : 16))
                        .foregroundStyle(.black.opacity(0.6))
                    Text(stats.learnedText)
                        .font(.system(size: isRegular ? 48 : 32, weight: .bold))
                        .foregroundStyle(.black)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Text("LEARNED")
                        .font(.system(size: isRegular ? 14 : 12, weight: .bold))
                        .foregroundStyle(Color(hex: 0x7C6172))
                        .tracking(1)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, isRegular ? 14 : 14)
                .background(Color.reviewsGreen, in: RoundedRectangle(cornerRadius: 18))

                VStack(spacing: isRegular ? 6 : 6) {
                    Image(systemName: "square.3.layers.3d")
                        .font(.system(size: isRegular ? 16 : 16))
                        .foregroundStyle(.black.opacity(0.6))
                    Text(stats.reviewsText)
                        .font(.system(size: isRegular ? 48 : 32, weight: .bold))
                        .foregroundStyle(.black)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Text("REVIEWS")
                        .font(.system(size: isRegular ? 14 : 12, weight: .bold))
                        .foregroundStyle(Color(hex: 0x7C6172))
                        .tracking(1)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, isRegular ? 20 : 14)
                .background(Color.reviewsGreen, in: RoundedRectangle(cornerRadius: 18))
            }
        }
        .padding(isRegular ? 16 : 10)
        .frame(maxHeight: .infinity)
        .background(Color.learnedGreen, in: RoundedRectangle(cornerRadius: isRegular ? 20 : 18))
    }
}

#Preview("iPhone") {
    StatsSectionView(stats: StatsViewData(
        streakText: "12",
        streakMessage: "Keep it up !",
        learnedText: "342",
        reviewsText: "1245"
    ))
    .padding()
    .background(Color.appBackground)
}

#Preview("iPad") {
    StatsSectionView(stats: StatsViewData(
        streakText: "12",
        streakMessage: "Keep it up !",
        learnedText: "342",
        reviewsText: "1245"
    ))
    .padding(64)
    .frame(width: 1440)
    .background(Color.appBackground)
}

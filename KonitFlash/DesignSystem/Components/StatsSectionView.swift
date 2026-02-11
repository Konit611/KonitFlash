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
            Image(systemName: "flame.fill")
                .font(.system(size: isRegular ? 34 : 20))
                .foregroundStyle(.orange)
                .padding(isRegular ? 10 : 5)
                .background(Color.white.opacity(0.5), in: Circle())

            Spacer()

            Text(stats.streakText)
                .font(.system(size: isRegular ? 64 : 36, weight: .bold))
                .foregroundStyle(.black)
            Text("STREAK", bundle: LanguageManager.shared.bundle)
                .font(.system(size: isRegular ? 20 : 14, weight: .bold))
                .foregroundStyle(Color(hex: 0x7C6172))
                .tracking(1)
                .padding(.top, 2)

            Spacer()

            Text(stats.streakMessage)
                .font(.system(size: isRegular ? 18 : 11, weight: .bold))
                .foregroundStyle(.black)
                .padding(.horizontal, isRegular ? 20 : 12)
                .padding(.vertical, isRegular ? 8 : 4)
                .background(Color.deckBadge, in: RoundedRectangle(cornerRadius: isRegular ? 8 : 6))
        }
        .padding(isRegular ? 24 : 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.streakPink, in: RoundedRectangle(cornerRadius: isRegular ? 20 : 18))
    }

    private var learnedReviewsCard: some View {
        VStack(alignment: .leading, spacing: isRegular ? 16 : 10) {
            Text("Let's crush more cards.", bundle: LanguageManager.shared.bundle)
                .font(.system(size: isRegular ? 22 : 14, weight: .bold))
                .foregroundStyle(.black)

            HStack(spacing: isRegular ? 12 : 5) {
                VStack(spacing: isRegular ? 8 : 6) {
                    Image(systemName: "book.fill")
                        .font(.system(size: isRegular ? 22 : 16))
                        .foregroundStyle(.black.opacity(0.6))
                    Text(stats.learnedText)
                        .font(.system(size: isRegular ? 64 : 32, weight: .bold))
                        .foregroundStyle(.black)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Text("LEARNED", bundle: LanguageManager.shared.bundle)
                        .font(.system(size: isRegular ? 18 : 12, weight: .bold))
                        .foregroundStyle(Color(hex: 0x7C6172))
                        .tracking(1)
                }
                .frame(maxWidth: .infinity, maxHeight: isRegular ? .infinity : nil)
                .padding(.vertical, isRegular ? 20 : 14)
                .background(Color.reviewsGreen, in: RoundedRectangle(cornerRadius: isRegular ? 20 : 18))

                VStack(spacing: isRegular ? 8 : 6) {
                    Image(systemName: "square.3.layers.3d")
                        .font(.system(size: isRegular ? 22 : 16))
                        .foregroundStyle(.black.opacity(0.6))
                    Text(stats.reviewsText)
                        .font(.system(size: isRegular ? 64 : 32, weight: .bold))
                        .foregroundStyle(.black)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Text("REVIEWS", bundle: LanguageManager.shared.bundle)
                        .font(.system(size: isRegular ? 18 : 12, weight: .bold))
                        .foregroundStyle(Color(hex: 0x7C6172))
                        .tracking(1)
                }
                .frame(maxWidth: .infinity, maxHeight: isRegular ? .infinity : nil)
                .padding(.vertical, isRegular ? 20 : 14)
                .background(Color.reviewsGreen, in: RoundedRectangle(cornerRadius: isRegular ? 20 : 18))
            }
            .frame(maxHeight: isRegular ? .infinity : nil)
        }
        .padding(isRegular ? 24 : 10)
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

import SwiftUI

struct DeckInfoCard: View {
    let deckName: String
    let description: String
    let dueTodayCount: Int
    let totalCards: String
    let progress: Double
    let progressPercent: String
    let progressColor: Color
    var onStartTap: (() -> Void)?
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    HStack(spacing: 6) {
                        Text("🔥")
                            .font(.system(size: isRegular ? 14 : 12))
                        Text("\(dueTodayCount) due today", bundle: LanguageManager.shared.bundle)
                            .font(.system(size: isRegular ? 18 : 14, weight: .bold))
                            .foregroundStyle(.black)
                    }
                    .padding(.horizontal, isRegular ? 16 : 12)
                    .padding(.vertical, isRegular ? 8 : 6)
                    .background(Color.deckBadge, in: RoundedRectangle(cornerRadius: 8))

                    if !isRegular {
                        Spacer()

                        Button {
                            onStartTap?()
                        } label: {
                            HStack(spacing: 4) {
                                Text("Start", bundle: LanguageManager.shared.bundle)
                                    .font(.system(size: 14, weight: .semibold))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 10, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(.black, in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(.bottom, isRegular ? 20 : 14)

                Text(deckName)
                    .font(.system(size: isRegular ? 36 : 24, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(.bottom, isRegular ? 8 : 6)

                Text(description)
                    .font(.system(size: isRegular ? 20 : 15))
                    .foregroundStyle(Color(hex: 0x555555))
                    .padding(.bottom, isRegular ? 20 : 14)

                Spacer(minLength: 0)

                HStack(spacing: 10) {
                    VStack(spacing: 2) {
                        Text(totalCards)
                            .font(.system(size: isRegular ? 24 : 16, weight: .bold))
                            .foregroundStyle(.black)
                        Text("Total", bundle: LanguageManager.shared.bundle)
                            .font(.system(size: isRegular ? 16 : 12))
                            .foregroundStyle(Color(hex: 0x555555))
                    }

                    VStack(spacing: 4) {
                        HStack {
                            Spacer()
                            Text(progressPercent)
                                .font(.system(size: isRegular ? 16 : 12, weight: .semibold))
                                .foregroundStyle(Color(hex: 0x9095A1))
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(.black)
                                    .frame(height: isRegular ? 15 : 7)
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(progressColor)
                                    .frame(width: geo.size.width * min(max(0, progress), 1), height: isRegular ? 13 : 5)
                                    .padding(.leading, 0.5)
                            }
                        }
                        .frame(height: isRegular ? 15 : 7)
                    }
                }
            }

            if isRegular {
                Spacer(minLength: 16)

                Button {
                    onStartTap?()
                } label: {
                    VStack(spacing: 6) {
                        Text("Start", bundle: LanguageManager.shared.bundle)
                            .font(.system(size: 18, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(width: 91, height: 117)
                    .background(.black, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(isRegular ? 24 : 20)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
    }
}

#Preview("iPhone") {
    DeckInfoCard(
        deckName: "English Vocabulary",
        description: "Essential Words for daily conservation",
        dueTodayCount: 12,
        totalCards: "126",
        progress: 0.6,
        progressPercent: "60%",
        progressColor: .streakPink
    )
    .padding()
    .background(Color.appBackground)
}

#Preview("Mac") {
    DeckInfoCard(
        deckName: "English Vocabulary",
        description: "Essential Words for daily conservation",
        dueTodayCount: 12,
        totalCards: "126",
        progress: 0.6,
        progressPercent: "60%",
        progressColor: .streakPink
    )
    .padding(64)
    .frame(width: 700)
    .background(Color.appBackground)
}

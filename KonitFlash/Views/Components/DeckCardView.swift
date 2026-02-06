import SwiftUI

struct DeckData: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let progress: Double
    let totalCards: Int
    let dueCards: Int
    let estimatedMinutes: Int
    let progressColor: Color
}

struct DeckCardView: View {
    let deck: DeckData

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title + menu
            HStack(alignment: .top) {
                Text(deck.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.black)
                Spacer()
                Button {
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black.opacity(0.4))
                        .padding(4)
                }
            }
            .padding(.bottom, 6)

            // Description
            Text(deck.description)
                .font(.system(size: 15))
                .foregroundStyle(Color(hex: 0x555555))
                .lineLimit(1)
                .padding(.bottom, 14)

            // Total count + progress bar
            HStack(spacing: 10) {
                VStack(spacing: 2) {
                    Text("\(deck.totalCards)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black)
                    Text("Total")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(hex: 0x555555))
                }

                VStack(spacing: 4) {
                    HStack {
                        Spacer()
                        Text("\(Int(deck.progress * 100))%")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color(hex: 0x9095A1))
                    }
                    // Custom progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 30)
                                .fill(.black)
                                .frame(height: 7)
                            RoundedRectangle(cornerRadius: 30)
                                .fill(deck.progressColor)
                                .frame(width: geo.size.width * deck.progress, height: 5)
                                .padding(.leading, 0.5)
                        }
                    }
                    .frame(height: 7)
                }
            }
            .padding(.bottom, 16)

            // Bottom action bar
            HStack(spacing: 0) {
                // Cards info
                HStack(spacing: 3) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.white)
                    Text("\(deck.dueCards)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                    Text("cards")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(hex: 0xC7C7C7))
                }

                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 1, height: 24)
                    .padding(.horizontal, 10)

                // Time info
                HStack(spacing: 3) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.white)
                    Text("\(deck.estimatedMinutes)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                    Text("min")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(hex: 0xC7C7C7))
                }

                Spacer(minLength: 8)

                // Start button
                Button {
                } label: {
                    HStack(spacing: 4) {
                        Text("Start")
                            .font(.system(size: 15, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(.white, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.black, in: RoundedRectangle(cornerRadius: 20))
        }
        .padding(20)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    VStack(spacing: 10) {
        DeckCardView(deck: DeckData(
            name: "English Vocabulary",
            description: "Essential Words for daily conservation",
            progress: 0.6,
            totalCards: 126,
            dueCards: 17,
            estimatedMinutes: 5,
            progressColor: Color.streakPink
        ))
        DeckCardView(deck: DeckData(
            name: "English Vocabulary",
            description: "Essential Words for daily conservation",
            progress: 0.6,
            totalCards: 126,
            dueCards: 17,
            estimatedMinutes: 5,
            progressColor: Color.learnedGreen
        ))
    }
    .padding()
    .background(Color.appBackground)
}

import SwiftUI

struct HomeView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass

    private let sampleDecks: [DeckData] = [
        DeckData(name: "English Vocabulary", description: "Essential Words for daily conservation", progress: 0.6, totalCards: 126, dueCards: 17, estimatedMinutes: 5, progressColor: Color.streakPink),
        DeckData(name: "English Vocabulary", description: "Essential Words for daily conservation", progress: 0.6, totalCards: 126, dueCards: 17, estimatedMinutes: 5, progressColor: Color.learnedGreen),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                header
                    .padding(.bottom, 10)
                OverdueBanner(count: 45)
                StatsSectionView()
                sectionDot
                WeeklyChartView()
                decksSection
            }
            .padding(.horizontal, 15)
            .padding(.top, 10)
        }
        .background(Color.appBackground)
    }

    private var header: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color.appBackground)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle().stroke(Color.learnedGreen.opacity(0.3), lineWidth: 1)
                    )
                Image(systemName: "bolt.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.learnedGreen)
            }
            Spacer()
            Button {
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
    }

    private var sectionDot: some View {
        Circle()
            .fill(Color.white.opacity(0.15))
            .frame(width: 15, height: 15)
            .padding(.vertical, 4)
    }

    private var decksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("My Flash Decks")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                Button {
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .medium))
                        Text("New Deck")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.white, in: RoundedRectangle(cornerRadius: 18))
                }
            }
            .padding(.top, 6)

            if sizeClass == .regular {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 3), spacing: 14) {
                    ForEach(sampleDecks) { deck in
                        DeckCardView(deck: deck)
                    }
                }
            } else {
                ForEach(sampleDecks) { deck in
                    DeckCardView(deck: deck)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}

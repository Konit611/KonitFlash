import SwiftUI

struct HomeView: View {
    @StateObject private var presenter = HomePresenter()
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }

    var body: some View {
        ScrollView {
            VStack(spacing: isRegular ? 14 : 5) {
                header
                    .padding(.bottom, isRegular ? 0 : 10)
                if presenter.viewState.showOverdueBanner {
                    OverdueBanner(count: presenter.viewState.overdueCount, isRegular: isRegular)
                }
                StatsSectionView(stats: presenter.viewState.stats)
                if !isRegular { sectionDot }
                WeeklyChartView(data: presenter.viewState.weeklyData)
                decksSection
            }
            .padding(.horizontal, isRegular ? 40 : 15)
            .padding(.top, isRegular ? 20 : 10)
        }
        .background(Color.appBackground)
        .navigationBarHidden(true)
        .navigationDestination(for: UUID.self) { deckID in
            DeckDetailView(deckID: deckID)
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.appBackground)
                        .frame(width: isRegular ? 50 : 40, height: isRegular ? 50 : 40)
                        .overlay(
                            Circle().stroke(Color.learnedGreen.opacity(0.3), lineWidth: 1)
                        )
                    Image(systemName: "bolt.fill")
                        .font(.system(size: isRegular ? 22 : 18, weight: .bold))
                        .foregroundStyle(Color.learnedGreen)
                }
                if isRegular {
                    Text("KONIT Flash")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            Spacer()
            Button {
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: isRegular ? 50 : 40, height: isRegular ? 50 : 40)
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: isRegular ? 22 : 18))
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

    // MARK: - Decks Section
    private var decksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("My Flash Decks")
                    .font(.system(size: isRegular ? 24 : 20, weight: .semibold))
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
                    .padding(.horizontal, isRegular ? 24 : 16)
                    .padding(.vertical, isRegular ? 10 : 8)
                    .background(.white, in: RoundedRectangle(cornerRadius: isRegular ? 12 : 18))
                }
            }
            .padding(.top, 6)

            let columns = isRegular ? 3 : 1
            if columns > 1 {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: columns), spacing: 16) {
                    ForEach(presenter.viewState.decks) { deck in
                        NavigationLink(value: deck.id) {
                            DeckCardView(deck: deck)
                        }
                    }
                }
            } else {
                ForEach(presenter.viewState.decks) { deck in
                    NavigationLink(value: deck.id) {
                        DeckCardView(deck: deck)
                    }
                }
            }
        }
    }
}

#Preview("iPhone") {
    HomeView()
}

#Preview("iPad") {
    HomeView()
}

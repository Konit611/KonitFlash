import SwiftUI

struct HomeView: View {
    @StateObject private var presenter = HomePresenter()
    @Binding var path: NavigationPath
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var deckToDelete: DeckViewData?

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
        .confirmationDialog(
            "Delete \"\(deckToDelete?.name ?? "")\"?",
            isPresented: Binding(
                get: { deckToDelete != nil },
                set: { if !$0 { deckToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let deck = deckToDelete {
                    presenter.deleteDeck(id: deck.id)
                    deckToDelete = nil
                }
            }
        } message: {
            Text("This deck and all its cards will be permanently deleted.")
        }
    }

    // MARK: - Header
    private var header: some View {
        AppHeaderView(showSettings: true)
    }

    private func deckCard(for deck: DeckViewData) -> some View {
        Button {
            path.append(NavigationRoute.deckDetail(deck.id))
        } label: {
            DeckCardView(
                deck: deck,
                onStartTap: { path.append(NavigationRoute.flashCard(deckID: deck.id)) },
                onEditTap: { path.append(NavigationRoute.editDeck(deckID: deck.id)) },
                onDeleteTap: { deckToDelete = deck }
            )
        }
        .buttonStyle(CardPressStyle())
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
                NavigationLink(value: NavigationRoute.addDeck) {
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
                        deckCard(for: deck)
                    }
                }
            } else {
                ForEach(presenter.viewState.decks) { deck in
                    deckCard(for: deck)
                }
            }
        }
    }
}

#Preview("iPhone") {
    ContentView()
}

#Preview("iPad") {
    ContentView()
}

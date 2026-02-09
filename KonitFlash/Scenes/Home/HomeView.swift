import SwiftUI
import SwiftData

struct HomeView: View {
    @StateObject private var presenter = HomePresenter()
    @Binding var path: NavigationPath
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.modelContext) private var modelContext
    @State private var deckToDelete: DeckViewData?

    private var isRegular: Bool { sizeClass == .regular }

    var body: some View {
        ScrollView {
            VStack(spacing: isRegular ? 14 : 5) {
                header
                    .padding(.bottom, isRegular ? 0 : 10)
                if presenter.viewState.showOverdueBanner {
                    OverdueBanner(
                        count: presenter.viewState.overdueCount,
                        isRegular: isRegular,
                        onCatchUp: {
                            if let deckID = presenter.viewState.firstOverdueDeckID {
                                path.append(NavigationRoute.flashCard(deckID: deckID))
                            }
                        }
                    )
                }
                StatsSectionView(stats: presenter.viewState.stats)
                    .overlay(alignment: .bottom) {
                        if !isRegular {
                            sectionDots
                        }
                    }
                    .zIndex(1)
                WeeklyChartView(data: presenter.viewState.weeklyData)
                decksSection
            }
            .padding(.horizontal, isRegular ? 40 : 15)
            .padding(.top, isRegular ? 20 : 10)
        }
        .background(Color.appBackground)
        .navigationBarHidden(true)
        .onAppear { presenter.configure(modelContext: modelContext) }
        .confirmationDialog(
            "Delete \"\(deckToDelete?.name ?? "")\"?",
            isPresented: Binding(
                get: { deckToDelete != nil },
                set: { if !$0 { deckToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button(String(localized: "Delete", bundle: LanguageManager.shared.bundle), role: .destructive) {
                if let deck = deckToDelete {
                    presenter.deleteDeck(id: deck.id)
                    deckToDelete = nil
                }
            }
        } message: {
            Text("This deck and all its cards will be permanently deleted.", bundle: LanguageManager.shared.bundle)
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

    private var sectionDots: some View {
        let streakRatio: CGFloat = 0.31
        let hSpacing: CGFloat = 5
        let dotSize: CGFloat = 15

        return GeometryReader { geo in
            let totalWidth = geo.size.width
            let streakWidth = totalWidth * streakRatio
            let rightWidth = totalWidth - streakWidth - hSpacing
            let leftX = streakWidth / 2 - dotSize / 2
            let rightX = streakWidth + hSpacing + rightWidth / 2 - dotSize / 2

            Circle()
                .fill(Color(hex: 0x2A2A2A))
                .frame(width: dotSize, height: dotSize)
                .offset(x: leftX)
            Circle()
                .fill(Color(hex: 0x2A2A2A))
                .frame(width: dotSize, height: dotSize)
                .offset(x: rightX)
        }
        .frame(height: 15)
        .offset(y: 7.5)
    }

    // MARK: - Decks Section
    private var decksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("My Flash Decks", bundle: LanguageManager.shared.bundle)
                    .font(.system(size: isRegular ? 24 : 20, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                NavigationLink(value: NavigationRoute.addDeck) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .medium))
                        Text("New Deck", bundle: LanguageManager.shared.bundle)
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, isRegular ? 24 : 16)
                    .padding(.vertical, isRegular ? 10 : 8)
                    .background(.white, in: RoundedRectangle(cornerRadius: isRegular ? 12 : 18))
                }
            }
            .padding(.top, 6)

            if !presenter.viewState.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.4))
                    TextField(String(localized: "Search decks...", bundle: LanguageManager.shared.bundle), text: $presenter.searchText)
                        .font(.system(size: isRegular ? 16 : 14))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
            }

            if presenter.viewState.isEmpty {
                EmptyStateView(
                    icon: "rectangle.stack",
                    title: String(localized: "No Decks Yet", bundle: LanguageManager.shared.bundle),
                    message: String(localized: "Create your first deck to start learning", bundle: LanguageManager.shared.bundle),
                    buttonTitle: String(localized: "Create Deck", bundle: LanguageManager.shared.bundle),
                    onButtonTap: { path.append(NavigationRoute.addDeck) }
                )
            } else {
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
}

#Preview("iPhone") {
    ContentView()
        .modelContainer(for: [Deck.self, Card.self, StudyLog.self], inMemory: true)
}

#Preview("iPad") {
    ContentView()
        .modelContainer(for: [Deck.self, Card.self, StudyLog.self], inMemory: true)
}

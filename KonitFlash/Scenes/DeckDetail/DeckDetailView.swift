import SwiftUI

struct DeckDetailView: View {
    @StateObject private var presenter: DeckDetailPresenter
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass

    private let deckID: UUID
    @State private var cardToDelete: CardRowData?
    @State private var navTarget: DetailNavTarget?
    private var isRegular: Bool { sizeClass == .regular }

    private enum DetailNavTarget: Hashable {
        case flashCard
        case editCard(UUID)
    }

    init(deckID: UUID) {
        self.deckID = deckID
        _presenter = StateObject(wrappedValue: DeckDetailPresenter(deckID: deckID))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: isRegular ? 14 : 10) {
                header
                    .padding(.bottom, isRegular ? 0 : 10)

                if isRegular {
                    HStack(spacing: 8) {
                        DeckInfoCard(
                            deckName: presenter.viewState.deckName,
                            description: presenter.viewState.deckDescription,
                            dueTodayCount: presenter.viewState.dueTodayCount,
                            totalCards: presenter.viewState.totalCards,
                            progress: presenter.viewState.progress,
                            progressPercent: presenter.viewState.progressPercent,
                            progressColor: presenter.viewState.progressColor,
                            onStartTap: startStudy
                        )

                        DeckStatsSection(
                            newCount: presenter.viewState.newCount,
                            learningCount: presenter.viewState.learningCount,
                            reviewedCount: presenter.viewState.reviewedCount
                        )
                    }
                    .frame(height: 241)
                } else {
                    DeckInfoCard(
                        deckName: presenter.viewState.deckName,
                        description: presenter.viewState.deckDescription,
                        dueTodayCount: presenter.viewState.dueTodayCount,
                        totalCards: presenter.viewState.totalCards,
                        progress: presenter.viewState.progress,
                        progressPercent: presenter.viewState.progressPercent,
                        progressColor: presenter.viewState.progressColor,
                        onStartTap: startStudy
                    )

                    DeckStatsSection(
                        newCount: presenter.viewState.newCount,
                        learningCount: presenter.viewState.learningCount,
                        reviewedCount: presenter.viewState.reviewedCount
                    )
                }

                cardsSection
            }
            .padding(.horizontal, isRegular ? 40 : 15)
            .padding(.top, isRegular ? 20 : 10)
        }
        .background(Color.appBackground)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: Binding(
            get: { navTarget != nil },
            set: { if !$0 { navTarget = nil } }
        )) {
            switch navTarget {
            case .flashCard:
                FlashCardView(deckID: deckID)
            case .editCard(let cardID):
                AddCardView(deckID: deckID, editingCardID: cardID)
            case nil:
                EmptyView()
            }
        }
        .confirmationDialog(
            "Delete \"\(cardToDelete?.name ?? "")\"?",
            isPresented: Binding(
                get: { cardToDelete != nil },
                set: { if !$0 { cardToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let card = cardToDelete {
                    presenter.deleteCard(id: card.id)
                    cardToDelete = nil
                }
            }
        } message: {
            Text("This card will be permanently deleted.")
        }
    }

    private func startStudy() {
        navTarget = .flashCard
    }

    // MARK: - Header

    private var header: some View {
        AppHeaderView(showSettings: true, onDismiss: { dismiss() })
    }

    // MARK: - Cards Section

    private var cardsSection: some View {
        VStack(spacing: isRegular ? 14 : 10) {
            HStack {
                Text(isRegular ? "My Flash Decks" : "Cards in Deck")
                    .font(.system(size: isRegular ? 32 : 20, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                NavigationLink(value: NavigationRoute.addCard(deckID: deckID)) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: isRegular ? 16 : 14, weight: .medium))
                        Text("Add Card")
                            .font(.system(size: isRegular ? 20 : 16, weight: .semibold))
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, isRegular ? 24 : 16)
                    .padding(.vertical, isRegular ? 12 : 8)
                    .background(.white, in: RoundedRectangle(cornerRadius: isRegular ? 12 : 18))
                }
            }
            .padding(.top, 6)

            ForEach(presenter.viewState.cards) { card in
                CardRowView(
                    card: card,
                    onEditTap: { navTarget = .editCard(card.id) },
                    onDeleteTap: { cardToDelete = card }
                )
            }
        }
    }
}

#Preview("iPhone") {
    NavigationStack {
        DeckDetailView(deckID: UUID())
    }
}

#Preview("Mac") {
    NavigationStack {
        DeckDetailView(deckID: UUID())
    }
    .frame(width: 1440, height: 900)
}

import SwiftUI
import SwiftData

struct DeckDetailView: View {
    @StateObject private var presenter = DeckDetailPresenter()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.modelContext) private var modelContext

    private let deckID: UUID
    @State private var cardToDelete: CardRowData?
    @State private var navTarget: DetailNavTarget?
    @State private var showNoDueCardsAlert = false
    private var isRegular: Bool { sizeClass == .regular }

    private enum DetailNavTarget: Hashable {
        case flashCard
        case addCard
        case editCard(UUID)
    }

    init(deckID: UUID) {
        self.deckID = deckID
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
                    VStack(spacing: 0) {
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

                        deckInfoDots
                            .zIndex(1)

                        DeckStatsSection(
                            newCount: presenter.viewState.newCount,
                            learningCount: presenter.viewState.learningCount,
                            reviewedCount: presenter.viewState.reviewedCount
                        )
                    }
                }

                cardsSection
            }
            .padding(.horizontal, isRegular ? 40 : 15)
            .padding(.top, isRegular ? 20 : 10)
        }
        .background(Color.appBackground)
        .navigationBarHidden(true)
        .onAppear { presenter.configure(modelContext: modelContext, deckID: deckID) }
        .onDisappear { WidgetDataService.writeWidgetData(from: modelContext) }
        .navigationDestination(isPresented: Binding(
            get: { navTarget != nil },
            set: { if !$0 { navTarget = nil } }
        )) {
            switch navTarget {
            case .flashCard:
                FlashCardView(deckID: deckID)
            case .addCard:
                AddCardView(deckID: deckID)
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
            Button(String(localized: "Delete", bundle: LanguageManager.shared.bundle), role: .destructive) {
                if let card = cardToDelete {
                    presenter.deleteCard(id: card.id)
                    cardToDelete = nil
                }
            }
        } message: {
            Text("This card will be permanently deleted.", bundle: LanguageManager.shared.bundle)
        }
        .alert(
            String(localized: "No Overdue Cards", bundle: LanguageManager.shared.bundle),
            isPresented: $showNoDueCardsAlert
        ) {
            Button(String(localized: "Done", bundle: LanguageManager.shared.bundle), role: .cancel) {}
        } message: {
            Text("You've completed all reviews for today", bundle: LanguageManager.shared.bundle)
        }
    }

    private var deckInfoDots: some View {
        HStack(spacing: 0) {
            ForEach(0..<3, id: \.self) { _ in
                Circle()
                    .fill(Color(hex: 0x2A2A2A))
                    .frame(width: 15, height: 15)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, -4)
    }

    private func startStudy() {
        if presenter.viewState.dueTodayCount > 0 {
            navTarget = .flashCard
        } else {
            showNoDueCardsAlert = true
        }
    }

    // MARK: - Header

    private var header: some View {
        AppHeaderView(onDismiss: { dismiss() })
    }

    // MARK: - Cards Section

    private var cardsSection: some View {
        VStack(spacing: isRegular ? 14 : 10) {
            HStack {
                Text("Cards in Deck", bundle: LanguageManager.shared.bundle)
                    .font(.system(size: isRegular ? 32 : 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Spacer()

                NavigationLink(value: NavigationRoute.csvImport(deckID: deckID)) {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.text")
                            .font(.system(size: isRegular ? 14 : 12, weight: .medium))
                        Text("Import", bundle: LanguageManager.shared.bundle)
                            .font(.system(size: isRegular ? 16 : 14, weight: .medium))
                            .lineLimit(1)
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, isRegular ? 16 : 12)
                    .padding(.vertical, isRegular ? 10 : 7)
                    .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: isRegular ? 12 : 18))
                }
                .fixedSize()

                NavigationLink(value: NavigationRoute.addCard(deckID: deckID)) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: isRegular ? 16 : 14, weight: .medium))
                        Text("Add Card", bundle: LanguageManager.shared.bundle)
                            .font(.system(size: isRegular ? 20 : 16, weight: .semibold))
                            .lineLimit(1)
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, isRegular ? 24 : 16)
                    .padding(.vertical, isRegular ? 12 : 8)
                    .background(.white, in: RoundedRectangle(cornerRadius: isRegular ? 12 : 18))
                }
                .fixedSize()
            }
            .padding(.top, 6)

            if presenter.viewState.isEmpty {
                EmptyStateView(
                    icon: "rectangle.on.rectangle",
                    title: String(localized: "No Cards Yet", bundle: LanguageManager.shared.bundle),
                    message: String(localized: "Add cards to start studying", bundle: LanguageManager.shared.bundle),
                    buttonTitle: String(localized: "Add Card", bundle: LanguageManager.shared.bundle),
                    onButtonTap: { navTarget = .addCard }
                )
            } else {
                // Search bar
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.4))
                    TextField(String(localized: "Search cards...", bundle: LanguageManager.shared.bundle), text: $presenter.searchText)
                        .font(.system(size: isRegular ? 16 : 14))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))

                // Filter chips
                HStack(spacing: 8) {
                    ForEach(CardFilter.allCases, id: \.self) { filter in
                        Button {
                            presenter.selectedFilter = filter
                        } label: {
                            Text(filter.localizedLabel)
                                .font(.system(size: isRegular ? 14 : 12, weight: .medium))
                                .foregroundStyle(presenter.selectedFilter == filter ? .black : .white.opacity(0.6))
                                .padding(.horizontal, isRegular ? 16 : 12)
                                .padding(.vertical, 6)
                                .background(
                                    presenter.selectedFilter == filter ? Color.learnedGreen : .white.opacity(0.08),
                                    in: RoundedRectangle(cornerRadius: 10)
                                )
                        }
                    }
                    Spacer()
                }

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
}

#Preview("iPhone") {
    NavigationStack {
        DeckDetailView(deckID: UUID())
    }
    .modelContainer(for: [Deck.self, Card.self, StudyLog.self], inMemory: true)
}

#Preview("Mac") {
    NavigationStack {
        DeckDetailView(deckID: UUID())
    }
    .frame(width: 1440, height: 900)
    .modelContainer(for: [Deck.self, Card.self, StudyLog.self], inMemory: true)
}

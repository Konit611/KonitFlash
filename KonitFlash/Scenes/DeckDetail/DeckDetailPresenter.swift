import Combine
import SwiftUI
import SwiftData

enum CardFilter: String, CaseIterable {
    case all = "All"
    case due = "Due"
    case newCards = "New"
    case learned = "Learned"
}

final class DeckDetailPresenter: ObservableObject {
    @Published var viewState = DeckDetailViewState()
    @Published var searchText: String = ""
    @Published var selectedFilter: CardFilter = .all

    private var interactor: DeckDetailInteractor?
    private var deckID: UUID?
    private var allCards: [CardRowData] = []
    private var cancellables = Set<AnyCancellable>()

    func configure(modelContext: ModelContext, deckID: UUID) {
        self.deckID = deckID

        if interactor != nil {
            loadData()
            return
        }
        self.interactor = DeckDetailInteractor(modelContext: modelContext)

        LanguageManager.shared.$locale
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.loadData() }
            .store(in: &cancellables)

        Publishers.CombineLatest($searchText, $selectedFilter)
            .dropFirst()
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] _, _ in self?.applyFilters() }
            .store(in: &cancellables)

        loadData()
    }

    func loadData() {
        guard let interactor, let deckID else { return }
        guard let data = interactor.fetchDeckDetail(deckID: deckID) else { return }

        allCards = mapCards(data.cards)

        viewState = DeckDetailViewState(
            deckName: data.deck.name,
            deckDescription: data.deck.deckDescription,
            dueTodayCount: data.dueTodayCount,
            totalCards: "\(data.deck.totalCards)",
            progress: data.deck.progress,
            progressPercent: "\(Int(data.deck.progress * 100))%",
            progressColor: colorForTag(data.deck.colorTagEnum),
            newCount: "\(data.newCount)",
            learningCount: "\(data.learningCount)",
            reviewedCount: "\(data.reviewedCount)",
            cards: filteredCards(),
            isEmpty: data.cards.isEmpty
        )
    }

    func deleteCard(id: UUID) {
        interactor?.deleteCard(id: id)
        loadData()
    }

    // MARK: - Filtering

    private func applyFilters() {
        viewState.cards = filteredCards()
    }

    private func filteredCards() -> [CardRowData] {
        var result = allCards

        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .due:
            result = result.filter { $0.isDue }
        case .newCards:
            result = result.filter { $0.isNew }
        case .learned:
            result = result.filter { !$0.isNew && !$0.isDue }
        }

        // Apply search
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        if !query.isEmpty {
            result = result.filter { $0.name.lowercased().contains(query) }
        }

        return result
    }

    // MARK: - Mapping

    private func mapCards(_ cards: [Card]) -> [CardRowData] {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let now = Date()

        let bundle = LanguageManager.shared.bundle
        return cards.map { card in
            CardRowData(
                id: card.id,
                name: card.front,
                dueDateText: String(localized: "Due: \(formatter.string(from: card.dueDate))", bundle: bundle),
                box: card.box,
                isNew: card.repetitions == 0,
                isDue: card.dueDate <= now
            )
        }
    }

    private func colorForTag(_ tag: ColorTag) -> Color {
        switch tag {
        case .pink: return .streakPink
        case .green: return .learnedGreen
        }
    }
}

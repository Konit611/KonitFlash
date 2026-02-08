import Combine
import SwiftUI

final class DeckDetailPresenter: ObservableObject {
    @Published var viewState = DeckDetailViewState()

    private let interactor: DeckDetailInteractor
    private let deckID: UUID
    private var cancellables = Set<AnyCancellable>()

    init(interactor: DeckDetailInteractor = DeckDetailInteractor(), deckID: UUID) {
        self.interactor = interactor
        self.deckID = deckID
        loadData()

        LanguageManager.shared.$locale
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.loadData() }
            .store(in: &cancellables)
    }

    func loadData() {
        let data = interactor.fetchDeckDetail(deckID: deckID)

        viewState = DeckDetailViewState(
            deckName: data.deck.name,
            deckDescription: data.deck.description,
            dueTodayCount: data.dueTodayCount,
            totalCards: "\(data.deck.totalCards)",
            progress: data.deck.progress,
            progressPercent: "\(Int(data.deck.progress * 100))%",
            progressColor: colorForTag(data.deck.colorTag),
            newCount: "\(data.newCount)",
            learningCount: "\(data.learningCount)",
            reviewedCount: "\(data.reviewedCount)",
            cards: mapCards(data.cards)
        )
    }

    func deleteCard(id: UUID) {
        viewState.cards.removeAll { $0.id == id }
    }

    // MARK: - Mapping

    private func mapCards(_ cards: [Card]) -> [CardRowData] {
        let formatter = DateFormatter()
        formatter.dateStyle = .short

        let bundle = LanguageManager.shared.bundle
        return cards.map { card in
            CardRowData(
                id: card.id,
                name: card.front,
                dueDateText: String(localized: "Due: \(formatter.string(from: card.dueDate))", bundle: bundle),
                box: card.box
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

import Combine
import SwiftUI

final class DeckDetailPresenter: ObservableObject {
    @Published var viewState = DeckDetailViewState()

    private let interactor: DeckDetailInteractor
    private let deckID: UUID

    init(interactor: DeckDetailInteractor = DeckDetailInteractor(), deckID: UUID) {
        self.interactor = interactor
        self.deckID = deckID
        loadData()
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

    // MARK: - Mapping

    private func mapCards(_ cards: [Card]) -> [CardRowData] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"

        return cards.map { card in
            CardRowData(
                id: card.id,
                name: card.front,
                dueDateText: "Due: \(formatter.string(from: card.dueDate))",
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

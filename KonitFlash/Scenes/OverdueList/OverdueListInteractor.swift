import Foundation
import SwiftData

final class OverdueListInteractor {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    struct OverdueDeckResult {
        let deckID: UUID
        let deckName: String
        let cards: [Card]
    }

    func fetchOverdueDecks() -> [OverdueDeckResult] {
        let descriptor = FetchDescriptor<Deck>()
        guard let decks = try? modelContext.fetch(descriptor) else { return [] }

        let now = Date()
        var results: [OverdueDeckResult] = []

        for deck in decks {
            let overdueCards = (deck.cards ?? [])
                .filter { $0.dueDate < now }
                .sorted { $0.dueDate < $1.dueDate }
            if !overdueCards.isEmpty {
                results.append(OverdueDeckResult(
                    deckID: deck.id,
                    deckName: deck.name,
                    cards: overdueCards
                ))
            }
        }

        return results
    }
}

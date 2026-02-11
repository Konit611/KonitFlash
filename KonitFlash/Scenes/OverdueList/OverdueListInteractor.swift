import Foundation
import SwiftData

final class OverdueListInteractor {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchOverdueCards() -> [(card: Card, deckName: String)] {
        let descriptor = FetchDescriptor<Deck>()
        guard let decks = try? modelContext.fetch(descriptor) else { return [] }

        let now = Date()
        var results: [(card: Card, deckName: String)] = []

        for deck in decks {
            let overdueCards = (deck.cards ?? []).filter { $0.dueDate < now }
            for card in overdueCards {
                results.append((card: card, deckName: deck.name))
            }
        }

        results.sort { $0.card.dueDate < $1.card.dueDate }
        return results
    }
}

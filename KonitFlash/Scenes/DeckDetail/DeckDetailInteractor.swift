import Foundation
import SwiftData

struct DeckDetailData {
    let deck: Deck
    let newCount: Int
    let learningCount: Int
    let reviewedCount: Int
    let dueTodayCount: Int
    let cards: [Card]
}

final class DeckDetailInteractor {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchDeckDetail(deckID: UUID) -> DeckDetailData? {
        let descriptor = FetchDescriptor<Deck>(predicate: #Predicate { $0.id == deckID })
        guard let deck = try? modelContext.fetch(descriptor).first else { return nil }

        let cards = (deck.cards ?? []).sorted { $0.createdAt < $1.createdAt }
        let now = Date()

        let newCount = cards.filter { $0.repetitions == 0 }.count
        let learningCount = cards.filter { $0.repetitions > 0 && $0.dueDate <= now }.count
        let reviewedCount = cards.filter { $0.repetitions > 0 && $0.dueDate > now }.count
        let dueTodayCount = cards.filter { $0.dueDate <= now }.count

        return DeckDetailData(
            deck: deck,
            newCount: newCount,
            learningCount: learningCount,
            reviewedCount: reviewedCount,
            dueTodayCount: dueTodayCount,
            cards: cards
        )
    }

    func deleteCard(id: UUID) {
        let descriptor = FetchDescriptor<Card>(predicate: #Predicate { $0.id == id })
        guard let card = try? modelContext.fetch(descriptor).first else { return }
        modelContext.delete(card)
        do {
            try modelContext.save()
        } catch {
            print("[KonitFlash] Failed to delete card: \(error)")
        }
    }
}

import Foundation
import os
import SwiftData

private let logger = Logger(subsystem: "geunil.KonitFlash", category: "AddCardInteractor")

struct AddCardInput {
    let deckID: UUID
    let front: String
    let back: String
}

struct AddCardData {
    let deckName: String
}

struct EditCardData {
    let deckName: String
    let front: String
    let back: String
}

final class AddCardInteractor {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchDeckInfo(deckID: UUID) -> AddCardData? {
        let descriptor = FetchDescriptor<Deck>(predicate: #Predicate { $0.id == deckID })
        guard let deck = try? modelContext.fetch(descriptor).first else { return nil }
        return AddCardData(deckName: deck.name)
    }

    func fetchCard(deckID: UUID, cardID: UUID) -> EditCardData? {
        let deckDescriptor = FetchDescriptor<Deck>(predicate: #Predicate { $0.id == deckID })
        guard let deck = try? modelContext.fetch(deckDescriptor).first else { return nil }

        let cardDescriptor = FetchDescriptor<Card>(predicate: #Predicate { $0.id == cardID })
        guard let card = try? modelContext.fetch(cardDescriptor).first else { return nil }

        return EditCardData(deckName: deck.name, front: card.front, back: card.back)
    }

    func saveCard(_ input: AddCardInput) {
        let targetDeckID = input.deckID
        let deckDescriptor = FetchDescriptor<Deck>(predicate: #Predicate { $0.id == targetDeckID })
        guard let deck = try? modelContext.fetch(deckDescriptor).first else { return }

        let card = Card(front: input.front, back: input.back, deck: deck)
        modelContext.insert(card)
        do {
            try modelContext.save()
        } catch {
            logger.error("Failed to save card: \(error)")
        }
    }

    func updateCard(cardID: UUID, input: AddCardInput) {
        let descriptor = FetchDescriptor<Card>(predicate: #Predicate { $0.id == cardID })
        guard let card = try? modelContext.fetch(descriptor).first else { return }
        card.front = input.front
        card.back = input.back
        card.updatedAt = Date()
        do {
            try modelContext.save()
        } catch {
            logger.error("Failed to update card: \(error)")
        }
    }
}

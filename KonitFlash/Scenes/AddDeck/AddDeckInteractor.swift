import Foundation
import os
import SwiftData

private let logger = Logger(subsystem: "geunil.KonitFlash", category: "AddDeckInteractor")

struct AddDeckInput {
    let name: String
    let description: String
    let colorTag: ColorTag
}

struct EditDeckData {
    let name: String
    let description: String
    let colorTag: ColorTag
}

final class AddDeckInteractor {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchDeck(deckID: UUID) -> EditDeckData? {
        let descriptor = FetchDescriptor<Deck>(predicate: #Predicate { $0.id == deckID })
        guard let deck = try? modelContext.fetch(descriptor).first else { return nil }
        return EditDeckData(
            name: deck.name,
            description: deck.deckDescription,
            colorTag: deck.colorTagEnum
        )
    }

    @discardableResult
    func saveDeck(_ input: AddDeckInput) -> Bool {
        let deck = Deck(name: input.name, deckDescription: input.description, colorTag: input.colorTag)
        modelContext.insert(deck)
        do {
            try modelContext.save()
            return true
        } catch {
            logger.error("Failed to save deck: \(error)")
            return false
        }
    }

    @discardableResult
    func updateDeck(deckID: UUID, input: AddDeckInput) -> Bool {
        let descriptor = FetchDescriptor<Deck>(predicate: #Predicate { $0.id == deckID })
        guard let deck = try? modelContext.fetch(descriptor).first else { return false }
        deck.name = input.name
        deck.deckDescription = input.description
        deck.colorTagEnum = input.colorTag
        deck.updatedAt = Date()
        do {
            try modelContext.save()
            return true
        } catch {
            logger.error("Failed to update deck: \(error)")
            return false
        }
    }
}

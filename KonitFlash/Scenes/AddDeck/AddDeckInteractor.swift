import Foundation
import SwiftData

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

    func saveDeck(_ input: AddDeckInput) {
        let deck = Deck(name: input.name, deckDescription: input.description, colorTag: input.colorTag)
        modelContext.insert(deck)
        do {
            try modelContext.save()
        } catch {
            print("[KonitFlash] Failed to save deck: \(error)")
        }
    }

    func updateDeck(deckID: UUID, input: AddDeckInput) {
        let descriptor = FetchDescriptor<Deck>(predicate: #Predicate { $0.id == deckID })
        guard let deck = try? modelContext.fetch(descriptor).first else { return }
        deck.name = input.name
        deck.deckDescription = input.description
        deck.colorTagEnum = input.colorTag
        deck.updatedAt = Date()
        do {
            try modelContext.save()
        } catch {
            print("[KonitFlash] Failed to update deck: \(error)")
        }
    }
}

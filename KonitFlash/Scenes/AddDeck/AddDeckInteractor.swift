import Foundation

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
    func fetchDeck(deckID: UUID) -> EditDeckData {
        // TODO: Fetch from DataStore
        EditDeckData(
            name: "English Vocabulary",
            description: "Essential Words for daily conservation",
            colorTag: .pink
        )
    }

    func saveDeck(_ input: AddDeckInput) {
        // TODO: Persist to DataStore
    }

    func updateDeck(deckID: UUID, input: AddDeckInput) {
        // TODO: Update in DataStore
    }
}

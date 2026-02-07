import Foundation

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
    func fetchDeckInfo(deckID: UUID) -> AddCardData {
        // TODO: Fetch from DataStore
        AddCardData(deckName: "English Vocabulary")
    }

    func fetchCard(deckID: UUID, cardID: UUID) -> EditCardData {
        // TODO: Fetch from DataStore
        EditCardData(
            deckName: "English Vocabulary",
            front: "Abandon",
            back: "포기하다, 버리다"
        )
    }

    func saveCard(_ input: AddCardInput) {
        // TODO: Persist to DataStore
    }

    func updateCard(cardID: UUID, input: AddCardInput) {
        // TODO: Update in DataStore
    }
}

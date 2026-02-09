import Testing
import Foundation
import SwiftData
@testable import KonitFlash

@MainActor
struct AddCardInteractorTests {
    private func makeContext() throws -> ModelContext {
        let schema = Schema([Deck.self, Card.self, StudyLog.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return container.mainContext
    }

    @Test func saveCardInsertsCard() throws {
        let context = try makeContext()
        let deck = Deck(name: "Test", deckDescription: "", colorTag: .pink)
        context.insert(deck)
        try context.save()

        let interactor = AddCardInteractor(modelContext: context)
        interactor.saveCard(AddCardInput(deckID: deck.id, front: "Hello", back: "World"))

        let cards = try context.fetch(FetchDescriptor<Card>())
        #expect(cards.count == 1)
        #expect(cards[0].front == "Hello")
        #expect(cards[0].back == "World")
        #expect(cards[0].deck?.id == deck.id)
    }

    @Test func fetchDeckInfoReturnsDeckName() throws {
        let context = try makeContext()
        let deck = Deck(name: "My Deck", deckDescription: "", colorTag: .green)
        context.insert(deck)
        try context.save()

        let interactor = AddCardInteractor(modelContext: context)
        let data = interactor.fetchDeckInfo(deckID: deck.id)
        #expect(data?.deckName == "My Deck")
    }

    @Test func fetchCardReturnsCardData() throws {
        let context = try makeContext()
        let deck = Deck(name: "Test", deckDescription: "", colorTag: .pink)
        context.insert(deck)
        let card = Card(front: "Q", back: "A", deck: deck)
        context.insert(card)
        try context.save()

        let interactor = AddCardInteractor(modelContext: context)
        let data = interactor.fetchCard(deckID: deck.id, cardID: card.id)
        #expect(data?.front == "Q")
        #expect(data?.back == "A")
        #expect(data?.deckName == "Test")
    }

    @Test func updateCardModifiesExisting() throws {
        let context = try makeContext()
        let deck = Deck(name: "Test", deckDescription: "", colorTag: .pink)
        context.insert(deck)
        let card = Card(front: "Old Front", back: "Old Back", deck: deck)
        context.insert(card)
        try context.save()

        let interactor = AddCardInteractor(modelContext: context)
        interactor.updateCard(cardID: card.id, input: AddCardInput(deckID: deck.id, front: "New Front", back: "New Back"))

        let updated = try context.fetch(FetchDescriptor<Card>())
        #expect(updated.count == 1)
        #expect(updated[0].front == "New Front")
        #expect(updated[0].back == "New Back")
    }
}

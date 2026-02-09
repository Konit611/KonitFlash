import Testing
import Foundation
import SwiftData
@testable import KonitFlash

@MainActor
struct AddDeckInteractorTests {
    private func makeContext() throws -> ModelContext {
        let schema = Schema([Deck.self, Card.self, StudyLog.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return container.mainContext
    }

    @Test func saveDeckInsertsDeck() throws {
        let context = try makeContext()
        let interactor = AddDeckInteractor(modelContext: context)

        interactor.saveDeck(AddDeckInput(name: "Test Deck", description: "Desc", colorTag: .pink))

        let decks = try context.fetch(FetchDescriptor<Deck>())
        #expect(decks.count == 1)
        #expect(decks[0].name == "Test Deck")
        #expect(decks[0].deckDescription == "Desc")
        #expect(decks[0].colorTagEnum == .pink)
    }

    @Test func fetchDeckReturnsData() throws {
        let context = try makeContext()
        let deck = Deck(name: "My Deck", deckDescription: "My Desc", colorTag: .green)
        context.insert(deck)
        try context.save()

        let interactor = AddDeckInteractor(modelContext: context)
        let data = interactor.fetchDeck(deckID: deck.id)

        #expect(data != nil)
        #expect(data?.name == "My Deck")
        #expect(data?.description == "My Desc")
        #expect(data?.colorTag == .green)
    }

    @Test func fetchDeckReturnsNilForUnknownID() throws {
        let context = try makeContext()
        let interactor = AddDeckInteractor(modelContext: context)
        #expect(interactor.fetchDeck(deckID: UUID()) == nil)
    }

    @Test func updateDeckModifiesExisting() throws {
        let context = try makeContext()
        let deck = Deck(name: "Old", deckDescription: "Old Desc", colorTag: .pink)
        context.insert(deck)
        try context.save()

        let interactor = AddDeckInteractor(modelContext: context)
        interactor.updateDeck(deckID: deck.id, input: AddDeckInput(name: "New", description: "New Desc", colorTag: .green))

        let updated = try context.fetch(FetchDescriptor<Deck>())
        #expect(updated.count == 1)
        #expect(updated[0].name == "New")
        #expect(updated[0].deckDescription == "New Desc")
        #expect(updated[0].colorTagEnum == .green)
    }
}

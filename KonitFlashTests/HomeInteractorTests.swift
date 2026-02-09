import Testing
import Foundation
import SwiftData
@testable import KonitFlash

@MainActor
struct HomeInteractorTests {
    private func makeContext() throws -> ModelContext {
        let schema = Schema([Deck.self, Card.self, StudyLog.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return container.mainContext
    }

    @Test func fetchHomeDataReturnsEmptyForNewStore() throws {
        let context = try makeContext()
        let interactor = HomeInteractor(modelContext: context)
        let data = interactor.fetchHomeData()
        #expect(data.decks.isEmpty)
        #expect(data.stats.overdueCount == 0)
        #expect(data.stats.learnedCount == 0)
        #expect(data.stats.reviewCount == 0)
        #expect(data.stats.streakDays == 0)
    }

    @Test func fetchHomeDataReturnsDeck() throws {
        let context = try makeContext()
        let deck = Deck(name: "Test", deckDescription: "Desc", colorTag: .pink)
        context.insert(deck)
        try context.save()

        let interactor = HomeInteractor(modelContext: context)
        let data = interactor.fetchHomeData()
        #expect(data.decks.count == 1)
        #expect(data.decks[0].name == "Test")
    }

    @Test func deleteDeckRemovesDeck() throws {
        let context = try makeContext()
        let deck = Deck(name: "ToDelete", deckDescription: "", colorTag: .green)
        context.insert(deck)
        try context.save()

        let interactor = HomeInteractor(modelContext: context)
        #expect(interactor.fetchHomeData().decks.count == 1)

        interactor.deleteDeck(id: deck.id)
        #expect(interactor.fetchHomeData().decks.isEmpty)
    }

    @Test func statsCountOverdueCards() throws {
        let context = try makeContext()
        let deck = Deck(name: "Test", deckDescription: "", colorTag: .pink)
        context.insert(deck)

        let pastCard = Card(front: "past", back: "past", deck: deck)
        pastCard.dueDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        context.insert(pastCard)

        let futureCard = Card(front: "future", back: "future", deck: deck)
        futureCard.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        context.insert(futureCard)

        try context.save()

        let interactor = HomeInteractor(modelContext: context)
        let data = interactor.fetchHomeData()
        #expect(data.stats.overdueCount == 1)
    }

    @Test func statsCountLearnedCards() throws {
        let context = try makeContext()
        let deck = Deck(name: "Test", deckDescription: "", colorTag: .pink)
        context.insert(deck)

        let learned = Card(front: "learned", back: "learned", deck: deck)
        learned.repetitions = 3
        context.insert(learned)

        let newCard = Card(front: "new", back: "new", deck: deck)
        context.insert(newCard)

        try context.save()

        let interactor = HomeInteractor(modelContext: context)
        let data = interactor.fetchHomeData()
        #expect(data.stats.learnedCount == 1)
    }

    @Test func weeklyActivityReturns7Days() throws {
        let context = try makeContext()
        let interactor = HomeInteractor(modelContext: context)
        let data = interactor.fetchHomeData()
        #expect(data.weeklyActivities.count == 7)
    }
}

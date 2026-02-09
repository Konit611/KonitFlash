import Testing
import Foundation
import SwiftData
@testable import KonitFlash

@MainActor
struct FlashCardInteractorTests {
    private func makeContext() throws -> ModelContext {
        let schema = Schema([Deck.self, Card.self, StudyLog.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return container.mainContext
    }

    @Test func fetchStudySessionReturnsEmptyForNoDueCards() throws {
        let context = try makeContext()
        let deck = Deck(name: "Test", deckDescription: "", colorTag: .pink)
        context.insert(deck)

        let card = Card(front: "F", back: "B", deck: deck)
        card.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        context.insert(card)
        try context.save()

        let interactor = FlashCardInteractor(modelContext: context)
        let session = interactor.fetchStudySession(deckID: deck.id)
        #expect(session.cards.isEmpty)
    }

    @Test func fetchStudySessionReturnsDueCards() throws {
        let context = try makeContext()
        let deck = Deck(name: "Test", deckDescription: "", colorTag: .pink)
        context.insert(deck)

        let card = Card(front: "F", back: "B", deck: deck)
        card.dueDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
        context.insert(card)
        try context.save()

        let interactor = FlashCardInteractor(modelContext: context)
        let session = interactor.fetchStudySession(deckID: deck.id)
        #expect(session.cards.count == 1)
        #expect(session.deckName == "Test")
    }

    @Test func fetchStudySessionLimitsTo20Cards() throws {
        let context = try makeContext()
        let deck = Deck(name: "Test", deckDescription: "", colorTag: .pink)
        context.insert(deck)

        for i in 0..<25 {
            let card = Card(front: "F\(i)", back: "B\(i)", deck: deck)
            card.dueDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
            context.insert(card)
        }
        try context.save()

        let interactor = FlashCardInteractor(modelContext: context)
        let session = interactor.fetchStudySession(deckID: deck.id)
        #expect(session.cards.count == 20)
    }

    @Test func recordAnswerUpdatesCard() throws {
        let context = try makeContext()
        let deck = Deck(name: "Test", deckDescription: "", colorTag: .pink)
        context.insert(deck)
        let card = Card(front: "F", back: "B", deck: deck)
        context.insert(card)
        try context.save()

        let interactor = FlashCardInteractor(modelContext: context)
        _ = interactor.fetchStudySession(deckID: deck.id)
        interactor.recordAnswer(card: card, grade: .good)

        #expect(card.repetitions == 1)
        #expect(card.interval > 0)
        #expect(card.dueDate > Date())
    }

    @Test func recordAnswerCreatesStudyLog() throws {
        let context = try makeContext()
        let deck = Deck(name: "Test", deckDescription: "", colorTag: .pink)
        context.insert(deck)
        let card = Card(front: "F", back: "B", deck: deck)
        context.insert(card)
        try context.save()

        let interactor = FlashCardInteractor(modelContext: context)
        _ = interactor.fetchStudySession(deckID: deck.id)
        interactor.recordAnswer(card: card, grade: .easy)

        let logDescriptor = FetchDescriptor<StudyLog>()
        let logs = try context.fetch(logDescriptor)
        #expect(logs.count == 1)
        #expect(logs[0].grade == 3) // easy = 3
    }

    @Test func computeStudyResultCountsGrades() throws {
        let context = try makeContext()
        let deck = Deck(name: "Test", deckDescription: "", colorTag: .pink)
        context.insert(deck)

        let cards = (0..<4).map { Card(front: "F\($0)", back: "B\($0)", deck: deck) }
        cards.forEach { context.insert($0) }
        try context.save()

        let interactor = FlashCardInteractor(modelContext: context)
        _ = interactor.fetchStudySession(deckID: deck.id)

        interactor.recordAnswer(card: cards[0], grade: .again)
        interactor.recordAnswer(card: cards[1], grade: .hard)
        interactor.recordAnswer(card: cards[2], grade: .good)
        interactor.recordAnswer(card: cards[3], grade: .easy)

        let result = interactor.computeStudyResult()
        #expect(result.totalCards == 4)
        #expect(result.againCount == 1)
        #expect(result.hardCount == 1)
        #expect(result.goodCount == 1)
        #expect(result.easyCount == 1)
        #expect(result.correctCount == 2)
    }

    @Test func computeIntervalsReturnsAllGrades() throws {
        let context = try makeContext()
        let card = Card(front: "F", back: "B")
        let interactor = FlashCardInteractor(modelContext: context)
        let intervals = interactor.computeIntervals(for: card)
        #expect(intervals.count == 4)
        #expect(intervals[.again] != nil)
        #expect(intervals[.hard] != nil)
        #expect(intervals[.good] != nil)
        #expect(intervals[.easy] != nil)
    }
}

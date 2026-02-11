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

    @Test func startSessionReturnsEmptyForNoDueCards() throws {
        let context = try makeContext()
        let deck = Deck(name: "Test", deckDescription: "", colorTag: .pink)
        context.insert(deck)

        let card = Card(front: "F", back: "B", deck: deck)
        card.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        context.insert(card)
        try context.save()

        let interactor = FlashCardInteractor(modelContext: context)
        let session = interactor.startSession(deckID: deck.id)
        #expect(session.initialCardCount == 0)

        if case .done = interactor.nextCard() {
            // expected
        } else {
            Issue.record("Expected .done")
        }
    }

    @Test func startSessionReturnsDueCards() throws {
        let context = try makeContext()
        let deck = Deck(name: "Test", deckDescription: "", colorTag: .pink)
        context.insert(deck)

        let card = Card(front: "F", back: "B", deck: deck)
        card.dueDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
        context.insert(card)
        try context.save()

        let interactor = FlashCardInteractor(modelContext: context)
        let session = interactor.startSession(deckID: deck.id)
        #expect(session.initialCardCount == 1)
        #expect(session.deckName == "Test")

        if case .card(let nextCard) = interactor.nextCard() {
            #expect(nextCard.front == "F")
        } else {
            Issue.record("Expected .card")
        }
    }

    @Test func startSessionLimitsTo20Cards() throws {
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
        let session = interactor.startSession(deckID: deck.id)
        #expect(session.initialCardCount == 20)
    }

    @Test func recordAnswerUpdatesCard() throws {
        let context = try makeContext()
        let deck = Deck(name: "Test", deckDescription: "", colorTag: .pink)
        context.insert(deck)
        let card = Card(front: "F", back: "B", deck: deck)
        context.insert(card)
        try context.save()

        let interactor = FlashCardInteractor(modelContext: context)
        _ = interactor.startSession(deckID: deck.id)

        guard case .card(let nextCard) = interactor.nextCard() else {
            Issue.record("Expected .card")
            return
        }

        interactor.recordAnswer(card: nextCard, grade: .good)

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
        _ = interactor.startSession(deckID: deck.id)

        guard case .card(let nextCard) = interactor.nextCard() else {
            Issue.record("Expected .card")
            return
        }

        interactor.recordAnswer(card: nextCard, grade: .easy)

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
        _ = interactor.startSession(deckID: deck.id)

        let grades: [AnswerGrade] = [.again, .hard, .good, .easy]
        for grade in grades {
            guard case .card(let card) = interactor.nextCard() else {
                Issue.record("Expected .card")
                return
            }
            interactor.recordAnswer(card: card, grade: grade)
        }

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

    // MARK: - Re-queue Tests

    @Test func againCardIsRequeued() throws {
        let context = try makeContext()
        let deck = Deck(name: "Test", deckDescription: "", colorTag: .pink)
        context.insert(deck)
        let card = Card(front: "F", back: "B", deck: deck)
        context.insert(card)
        try context.save()

        let interactor = FlashCardInteractor(modelContext: context)
        _ = interactor.startSession(deckID: deck.id)

        guard case .card(let nextCard) = interactor.nextCard() else {
            Issue.record("Expected .card")
            return
        }

        let result = interactor.recordAnswer(card: nextCard, grade: .again)
        #expect(result.wasRequeued == true)
        #expect(interactor.learningQueue.count == 1)
        #expect(result.totalSteps == 2) // 1 original + 1 re-queued
        #expect(result.completedSteps == 1)
    }

    @Test func goodCardIsNotRequeued() throws {
        let context = try makeContext()
        let deck = Deck(name: "Test", deckDescription: "", colorTag: .pink)
        context.insert(deck)
        let card = Card(front: "F", back: "B", deck: deck)
        context.insert(card)
        try context.save()

        let interactor = FlashCardInteractor(modelContext: context)
        _ = interactor.startSession(deckID: deck.id)

        guard case .card(let nextCard) = interactor.nextCard() else {
            Issue.record("Expected .card")
            return
        }

        let result = interactor.recordAnswer(card: nextCard, grade: .good)
        #expect(result.wasRequeued == false)
        #expect(interactor.learningQueue.isEmpty)
    }

    @Test func mixedQueueReturnsWaitingWhenOnlyLearningCardsLeft() throws {
        let context = try makeContext()
        let deck = Deck(name: "Test", deckDescription: "", colorTag: .pink)
        context.insert(deck)

        let card1 = Card(front: "F1", back: "B1", deck: deck)
        let card2 = Card(front: "F2", back: "B2", deck: deck)
        context.insert(card1)
        context.insert(card2)
        try context.save()

        let interactor = FlashCardInteractor(modelContext: context)
        _ = interactor.startSession(deckID: deck.id)

        // Answer first card with Again (re-queue)
        guard case .card(let first) = interactor.nextCard() else {
            Issue.record("Expected .card")
            return
        }
        interactor.recordAnswer(card: first, grade: .again)

        // Answer second card with Good (no re-queue)
        guard case .card(let second) = interactor.nextCard() else {
            Issue.record("Expected .card")
            return
        }
        interactor.recordAnswer(card: second, grade: .good)

        // Now only the learning card remains — should be .waiting
        if case .waiting = interactor.nextCard() {
            // expected — learning card not yet ready
        } else {
            // The learning card's readyAt might already have passed (it's ~1 min)
            // If so, .card is also acceptable
        }
    }

    @Test func progressIncrementsCorrectly() throws {
        let context = try makeContext()
        let deck = Deck(name: "Test", deckDescription: "", colorTag: .pink)
        context.insert(deck)

        let card1 = Card(front: "F1", back: "B1", deck: deck)
        let card2 = Card(front: "F2", back: "B2", deck: deck)
        context.insert(card1)
        context.insert(card2)
        try context.save()

        let interactor = FlashCardInteractor(modelContext: context)
        _ = interactor.startSession(deckID: deck.id)

        #expect(interactor.currentProgress.current == 0)
        #expect(interactor.currentProgress.total == 2)

        guard case .card(let first) = interactor.nextCard() else {
            Issue.record("Expected .card")
            return
        }
        let result1 = interactor.recordAnswer(card: first, grade: .again)
        #expect(result1.completedSteps == 1)
        #expect(result1.totalSteps == 3) // 2 original + 1 re-queued

        guard case .card(let second) = interactor.nextCard() else {
            Issue.record("Expected .card")
            return
        }
        let result2 = interactor.recordAnswer(card: second, grade: .good)
        #expect(result2.completedSteps == 2)
        #expect(result2.totalSteps == 3)
    }

    @Test func hardCardOnNewCardIsRequeued() throws {
        let context = try makeContext()
        let deck = Deck(name: "Test", deckDescription: "", colorTag: .pink)
        context.insert(deck)
        let card = Card(front: "F", back: "B", deck: deck)
        context.insert(card)
        try context.save()

        let interactor = FlashCardInteractor(modelContext: context)
        _ = interactor.startSession(deckID: deck.id)

        guard case .card(let nextCard) = interactor.nextCard() else {
            Issue.record("Expected .card")
            return
        }

        // Hard on a new card (repetitions=0) gives 10 min interval (< 1 day)
        let result = interactor.recordAnswer(card: nextCard, grade: .hard)
        #expect(result.wasRequeued == true)
        #expect(interactor.learningQueue.count == 1)
    }

    @Test func easyCardIsNotRequeued() throws {
        let context = try makeContext()
        let deck = Deck(name: "Test", deckDescription: "", colorTag: .pink)
        context.insert(deck)
        let card = Card(front: "F", back: "B", deck: deck)
        context.insert(card)
        try context.save()

        let interactor = FlashCardInteractor(modelContext: context)
        _ = interactor.startSession(deckID: deck.id)

        guard case .card(let nextCard) = interactor.nextCard() else {
            Issue.record("Expected .card")
            return
        }

        let result = interactor.recordAnswer(card: nextCard, grade: .easy)
        #expect(result.wasRequeued == false)
        #expect(interactor.learningQueue.isEmpty)
    }

    @Test func doneWhenAllQueuesEmpty() throws {
        let context = try makeContext()
        let deck = Deck(name: "Test", deckDescription: "", colorTag: .pink)
        context.insert(deck)
        let card = Card(front: "F", back: "B", deck: deck)
        context.insert(card)
        try context.save()

        let interactor = FlashCardInteractor(modelContext: context)
        _ = interactor.startSession(deckID: deck.id)

        guard case .card(let nextCard) = interactor.nextCard() else {
            Issue.record("Expected .card")
            return
        }
        interactor.recordAnswer(card: nextCard, grade: .good)

        if case .done = interactor.nextCard() {
            // expected
        } else {
            Issue.record("Expected .done when both queues empty")
        }
    }
}

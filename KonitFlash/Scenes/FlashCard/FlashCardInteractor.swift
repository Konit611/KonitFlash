import Foundation
import os
import SwiftData

private let logger = Logger(subsystem: "geunil.KonitFlash", category: "FlashCardInteractor")

struct SessionInfo {
    let deckName: String
    let initialCardCount: Int
}

struct LearningEntry {
    let card: Card
    let readyAt: Date
}

enum NextCardResult {
    case card(Card)
    case waiting(until: Date)
    case done
}

struct AnswerResult {
    let wasRequeued: Bool
    let completedSteps: Int
    let totalSteps: Int
}

final class FlashCardInteractor {
    private let modelContext: ModelContext
    private var answers: [(card: Card, grade: AnswerGrade)] = []
    private var startDate = Date()
    private var lastAnswerTime = Date()

    private(set) var reviewQueue: [Card] = []
    private(set) var learningQueue: [LearningEntry] = []
    private(set) var totalSteps: Int = 0
    private(set) var completedSteps: Int = 0

    var currentProgress: (current: Int, total: Int) {
        (completedSteps, totalSteps)
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func startSession(deckID: UUID) -> SessionInfo {
        startDate = Date()
        lastAnswerTime = startDate
        answers = []
        learningQueue = []
        completedSteps = 0

        let deckDescriptor = FetchDescriptor<Deck>(predicate: #Predicate { $0.id == deckID })
        guard let deck = try? modelContext.fetch(deckDescriptor).first else {
            reviewQueue = []
            totalSteps = 0
            return SessionInfo(deckName: "", initialCardCount: 0)
        }

        let now = Date()
        let limit = SettingsInteractor.currentSessionCardLimit()
        let effectiveLimit = limit > 0 ? limit : Int.max
        let dueCards = (deck.cards ?? [])
            .filter { $0.dueDate <= now }
            .sorted { $0.dueDate < $1.dueDate }
            .prefix(effectiveLimit)

        reviewQueue = Array(dueCards)
        totalSteps = reviewQueue.count

        return SessionInfo(deckName: deck.name, initialCardCount: reviewQueue.count)
    }

    func nextCard() -> NextCardResult {
        // 1. Check learning queue for ready cards
        let now = Date()
        if let readyIndex = learningQueue.firstIndex(where: { $0.readyAt <= now }) {
            let entry = learningQueue.remove(at: readyIndex)
            return .card(entry.card)
        }

        // 2. Check review queue
        if !reviewQueue.isEmpty {
            return .card(reviewQueue.removeFirst())
        }

        // 3. Check if learning cards are waiting
        if let earliest = learningQueue.min(by: { $0.readyAt < $1.readyAt }) {
            return .waiting(until: earliest.readyAt)
        }

        // 4. All done
        return .done
    }

    func computeIntervals(for card: Card, bundle: Bundle = .main) -> [AnswerGrade: String] {
        SRSEngine.previewIntervals(
            currentInterval: card.interval,
            currentEF: card.easeFactor,
            currentRepetitions: card.repetitions,
            currentBox: card.box,
            bundle: bundle
        )
    }

    @discardableResult
    func recordAnswer(card: Card, grade: AnswerGrade) -> AnswerResult {
        answers.append((card: card, grade: grade))

        let result = SRSEngine.compute(
            grade: grade,
            currentInterval: card.interval,
            currentEF: card.easeFactor,
            currentRepetitions: card.repetitions,
            currentBox: card.box
        )

        card.interval = result.interval
        card.easeFactor = result.easeFactor
        card.repetitions = result.repetitions
        card.dueDate = result.dueDate
        card.box = result.box
        card.updatedAt = Date()

        let now = Date()
        let elapsed = now.timeIntervalSince(lastAnswerTime)
        lastAnswerTime = now
        let log = StudyLog(card: card, grade: gradeToInt(grade), elapsedSeconds: elapsed)
        modelContext.insert(log)

        do {
            try modelContext.save()
        } catch {
            logger.error("Failed to save answer: \(error)")
        }

        // Re-queue intraday cards (interval < 1 day)
        let wasRequeued = result.interval < 1.0
        if wasRequeued {
            learningQueue.append(LearningEntry(card: card, readyAt: result.dueDate))
            totalSteps += 1
        }

        completedSteps += 1

        return AnswerResult(
            wasRequeued: wasRequeued,
            completedSteps: completedSteps,
            totalSteps: totalSteps
        )
    }

    func computeStudyResult() -> StudyResult {
        let elapsed = Date().timeIntervalSince(startDate)
        let againCount = answers.filter { $0.grade == .again }.count
        let hardCount = answers.filter { $0.grade == .hard }.count
        let goodCount = answers.filter { $0.grade == .good }.count
        let easyCount = answers.filter { $0.grade == .easy }.count
        let correctCount = goodCount + easyCount

        return StudyResult(
            totalCards: answers.count,
            correctCount: correctCount,
            againCount: againCount,
            hardCount: hardCount,
            goodCount: goodCount,
            easyCount: easyCount,
            elapsedSeconds: elapsed
        )
    }

    func restartWithPreviousCards() -> SessionInfo {
        let previousCards = answers.map { $0.card }
        let deckName = previousCards.first?.deck?.name ?? ""

        startDate = Date()
        lastAnswerTime = startDate
        answers = []
        learningQueue = []
        completedSteps = 0

        reviewQueue = previousCards
        totalSteps = reviewQueue.count

        return SessionInfo(deckName: deckName, initialCardCount: reviewQueue.count)
    }

    // MARK: - Private

    private func gradeToInt(_ grade: AnswerGrade) -> Int {
        switch grade {
        case .again: return 0
        case .hard: return 1
        case .good: return 2
        case .easy: return 3
        }
    }
}

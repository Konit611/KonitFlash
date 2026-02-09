import Foundation
import SwiftData

struct StudySession {
    let deckName: String
    let cards: [Card]
}

final class FlashCardInteractor {
    private let modelContext: ModelContext
    private var answers: [(card: Card, grade: AnswerGrade)] = []
    private var startDate = Date()

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchStudySession(deckID: UUID) -> StudySession {
        startDate = Date()
        answers = []

        let deckDescriptor = FetchDescriptor<Deck>(predicate: #Predicate { $0.id == deckID })
        guard let deck = try? modelContext.fetch(deckDescriptor).first else {
            return StudySession(deckName: "", cards: [])
        }

        let now = Date()
        let dueCards = (deck.cards ?? [])
            .filter { $0.dueDate <= now }
            .sorted { $0.dueDate < $1.dueDate }
            .prefix(20)

        return StudySession(deckName: deck.name, cards: Array(dueCards))
    }

    func computeIntervals(for card: Card) -> [AnswerGrade: String] {
        SRSEngine.previewIntervals(
            currentInterval: card.interval,
            currentEF: card.easeFactor,
            currentRepetitions: card.repetitions,
            currentBox: card.box
        )
    }

    func recordAnswer(card: Card, grade: AnswerGrade) {
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

        let elapsed = Date().timeIntervalSince(startDate) / Double(max(1, answers.count))
        let log = StudyLog(card: card, grade: gradeToInt(grade), elapsedSeconds: elapsed)
        modelContext.insert(log)

        try? modelContext.save()
    }

    func computeStudyResult() -> StudyResult {
        let elapsed = Int(Date().timeIntervalSince(startDate))
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

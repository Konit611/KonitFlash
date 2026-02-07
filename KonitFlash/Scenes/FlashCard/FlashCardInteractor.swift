import Foundation

struct StudySession {
    let deckName: String
    let cards: [Card]
}

final class FlashCardInteractor {
    private var answers: [(card: Card, grade: AnswerGrade)] = []
    private var startDate = Date()

    func fetchStudySession(deckID: UUID) -> StudySession {
        startDate = Date()
        answers = []

        let baseDate = Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 28))!

        let sampleCards = [
            Card(front: "Abandon", back: "포기하다, 버리다", dueDate: baseDate, box: 1),
            Card(front: "Benefit", back: "이익, 혜택", dueDate: baseDate, box: 2),
            Card(front: "Curious", back: "궁금한, 호기심 많은", dueDate: baseDate, box: 3),
            Card(front: "Diligent", back: "근면한, 성실한", dueDate: baseDate, box: 1),
            Card(front: "Elaborate", back: "정교한, 상세한", dueDate: baseDate, box: 4),
        ]

        return StudySession(deckName: "English Vocabulary", cards: sampleCards)
    }

    func computeIntervals(for card: Card) -> [AnswerGrade: String] {
        let box = card.box
        return [
            .again: "<1 min",
            .hard: box <= 1 ? "1 min" : "\(box) min",
            .good: box <= 1 ? "1 day" : "\(box) days",
            .easy: box <= 1 ? "4 days" : "\(box * 2) days"
        ]
    }

    func recordAnswer(card: Card, grade: AnswerGrade) {
        answers.append((card: card, grade: grade))
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
}

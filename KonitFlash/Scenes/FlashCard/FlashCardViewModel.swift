import Foundation

enum FlashCardPhase {
    case studying
    case waiting
    case result
    case empty
}

struct FlashCardViewState {
    var phase: FlashCardPhase = .studying
    var deckName: String = ""
    var currentIndex: Int = 0
    var totalCount: Int = 0
    var currentFront: String = ""
    var currentBack: String = ""
    var isFlipped: Bool = false
    var intervals: [AnswerGrade: String] = [:]

    // Waiting
    var waitingCountdown: String = ""
    var waitingMessage: String = ""

    // Result
    var accuracyPercent: Double = 0
    var totalCards: Int = 0
    var elapsedTime: String = "0:00"
    var goodEasyCount: Int = 0
    var againHardCount: Int = 0
    var resultMessage: String = ""
}

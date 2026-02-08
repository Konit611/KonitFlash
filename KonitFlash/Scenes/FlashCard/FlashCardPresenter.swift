import Combine
import Foundation

final class FlashCardPresenter: ObservableObject {
    @Published var viewState = FlashCardViewState()

    private let interactor: FlashCardInteractor
    private let deckID: UUID
    private var cards: [Card] = []
    private var currentCardIndex: Int = 0

    init(interactor: FlashCardInteractor = FlashCardInteractor(), deckID: UUID) {
        self.interactor = interactor
        self.deckID = deckID
        loadData()
    }

    func loadData() {
        let session = interactor.fetchStudySession(deckID: deckID)
        cards = session.cards
        currentCardIndex = 0

        viewState.deckName = session.deckName
        viewState.totalCount = cards.count
        viewState.phase = .studying

        showCurrentCard()
    }

    func answerCard(grade: AnswerGrade) {
        guard currentCardIndex < cards.count else { return }

        let card = cards[currentCardIndex]
        interactor.recordAnswer(card: card, grade: grade)

        currentCardIndex += 1

        if currentCardIndex >= cards.count {
            showResult()
        } else {
            showCurrentCard()
        }
    }

    func flipCard() {
        viewState.isFlipped = true
    }

    func restartSession() {
        loadData()
    }

    // MARK: - Private

    private func showCurrentCard() {
        guard currentCardIndex < cards.count else { return }

        let card = cards[currentCardIndex]
        viewState.currentIndex = currentCardIndex + 1
        viewState.currentFront = card.front
        viewState.currentBack = card.back
        viewState.isFlipped = false
        viewState.intervals = interactor.computeIntervals(for: card)
    }

    private func showResult() {
        let result = interactor.computeStudyResult()

        let accuracy = result.totalCards > 0
            ? Double(result.correctCount) / Double(result.totalCards) * 100
            : 0

        let minutes = result.elapsedSeconds / 60
        let seconds = result.elapsedSeconds % 60
        let timeText = "\(minutes):\(String(format: "%02d", seconds))"

        let bundle = LanguageManager.shared.bundle
        let message: String
        if accuracy >= 80 {
            message = String(localized: "Excellent work! Keep it up!", bundle: bundle)
        } else if accuracy >= 60 {
            message = String(localized: "Good effort! Practice makes perfect.", bundle: bundle)
        } else {
            message = String(localized: "Keep studying! You'll get there.", bundle: bundle)
        }

        viewState.phase = .result
        viewState.accuracyPercent = accuracy
        viewState.totalCards = result.totalCards
        viewState.elapsedTime = timeText
        viewState.goodEasyCount = result.goodCount + result.easyCount
        viewState.againHardCount = result.againCount + result.hardCount
        viewState.resultMessage = message
    }
}

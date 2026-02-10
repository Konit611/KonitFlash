import Combine
import Foundation
import SwiftData

final class FlashCardPresenter: ObservableObject {
    @Published var viewState = FlashCardViewState()

    private var interactor: FlashCardInteractor?
    private var deckID: UUID?
    private var cards: [Card] = []
    private var currentCardIndex: Int = 0

    func configure(modelContext: ModelContext, deckID: UUID) {
        self.deckID = deckID

        if interactor != nil {
            loadData()
            return
        }
        self.interactor = FlashCardInteractor(modelContext: modelContext)
        loadData()
    }

    func loadData() {
        guard let interactor, let deckID else { return }
        let session = interactor.fetchStudySession(deckID: deckID)
        cards = session.cards
        currentCardIndex = 0

        viewState.deckName = session.deckName
        viewState.totalCount = cards.count

        if cards.isEmpty {
            viewState.phase = .empty
        } else {
            viewState.phase = .studying
            showCurrentCard()
        }
    }

    func answerCard(grade: AnswerGrade) {
        guard let interactor, currentCardIndex < cards.count else { return }

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
        guard let interactor, currentCardIndex < cards.count else { return }

        let card = cards[currentCardIndex]
        viewState.currentIndex = currentCardIndex + 1
        viewState.currentFront = card.front
        viewState.currentBack = card.back
        viewState.isFlipped = false
        viewState.intervals = interactor.computeIntervals(for: card, bundle: LanguageManager.shared.bundle)
    }

    private func showResult() {
        guard let interactor else { return }
        let result = interactor.computeStudyResult()

        let accuracy = result.totalCards > 0
            ? Double(result.correctCount) / Double(result.totalCards) * 100
            : 0

        let totalSeconds = Int(result.elapsedSeconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        let timeText: String
        if hours > 0 {
            timeText = "\(hours):\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
        } else {
            timeText = "\(minutes):\(String(format: "%02d", seconds))"
        }

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

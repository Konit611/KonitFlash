import Combine
import Foundation
import SwiftData

final class FlashCardPresenter: ObservableObject {
    @Published var viewState = FlashCardViewState()

    private var interactor: FlashCardInteractor?
    private var deckID: UUID?
    private var currentCard: Card?
    private var waitingTimer: Timer?

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
        stopTimer()

        let session = interactor.startSession(deckID: deckID)

        viewState.deckName = session.deckName
        viewState.totalCount = session.initialCardCount

        if session.initialCardCount == 0 {
            viewState.phase = .empty
        } else {
            advanceToNextCard()
        }
    }

    func answerCard(grade: AnswerGrade) {
        guard let interactor, let card = currentCard else { return }
        currentCard = nil

        interactor.recordAnswer(card: card, grade: grade)
        advanceToNextCard()
    }

    func flipCard() {
        viewState.isFlipped = true
    }

    func skipWaiting() {
        stopTimer()
        showResult()
    }

    func restartSession() {
        guard let interactor else { return }
        stopTimer()

        let session = interactor.restartWithPreviousCards()
        viewState.deckName = session.deckName
        viewState.totalCount = session.initialCardCount

        if session.initialCardCount == 0 {
            viewState.phase = .empty
        } else {
            advanceToNextCard()
        }
    }

    deinit {
        waitingTimer?.invalidate()
    }

    // MARK: - Private

    private func advanceToNextCard() {
        guard let interactor else { return }

        let progress = interactor.currentProgress
        viewState.currentIndex = progress.current
        viewState.totalCount = progress.total

        switch interactor.nextCard() {
        case .card(let card):
            currentCard = card
            showCard(card)
        case .waiting(let until):
            currentCard = nil
            startWaiting(until: until)
        case .done:
            currentCard = nil
            showResult()
        }
    }

    private func showCard(_ card: Card) {
        guard let interactor else { return }
        stopTimer()

        let progress = interactor.currentProgress
        viewState.phase = .studying
        viewState.currentIndex = progress.current + 1
        viewState.totalCount = progress.total
        viewState.currentFront = card.front
        viewState.currentBack = card.back
        viewState.isFlipped = false
        viewState.intervals = interactor.computeIntervals(for: card, bundle: LanguageManager.shared.bundle)
    }

    private func startWaiting(until readyAt: Date) {
        let bundle = LanguageManager.shared.bundle
        viewState.phase = .waiting
        viewState.waitingMessage = String(localized: "Learning cards will reappear when ready", bundle: bundle)
        updateCountdown(until: readyAt)

        waitingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            let now = Date()
            if now >= readyAt {
                self.stopTimer()
                self.advanceToNextCard()
            } else {
                self.updateCountdown(until: readyAt)
            }
        }
    }

    private func updateCountdown(until readyAt: Date) {
        let remaining = max(0, Int(readyAt.timeIntervalSinceNow.rounded(.up)))
        let minutes = remaining / 60
        let seconds = remaining % 60
        viewState.waitingCountdown = String(format: "%d:%02d", minutes, seconds)
    }

    private func stopTimer() {
        waitingTimer?.invalidate()
        waitingTimer = nil
    }

    private func showResult() {
        guard let interactor else { return }
        let result = interactor.computeStudyResult()

        let accuracy = result.totalCards > 0
            ? Double(result.correctCount) / Double(result.totalCards) * 100
            : 0

        viewState.phase = .result
        viewState.accuracyPercent = accuracy
        viewState.totalCards = result.totalCards
        viewState.elapsedTime = formatElapsedTime(result.elapsedSeconds)
        viewState.goodEasyCount = result.goodCount + result.easyCount
        viewState.againHardCount = result.againCount + result.hardCount
        viewState.resultMessage = resultMessage(for: accuracy)
    }

    private func formatElapsedTime(_ seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let secs = totalSeconds % 60
        if hours > 0 {
            return "\(hours):\(String(format: "%02d", minutes)):\(String(format: "%02d", secs))"
        }
        return "\(minutes):\(String(format: "%02d", secs))"
    }

    private func resultMessage(for accuracy: Double) -> String {
        let bundle = LanguageManager.shared.bundle
        if accuracy >= 80 {
            return String(localized: "Excellent work! Keep it up!", bundle: bundle)
        } else if accuracy >= 60 {
            return String(localized: "Good effort! Practice makes perfect.", bundle: bundle)
        }
        return String(localized: "Keep studying! You'll get there.", bundle: bundle)
    }
}

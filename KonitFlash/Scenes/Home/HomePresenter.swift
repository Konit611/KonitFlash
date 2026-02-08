import Combine
import SwiftUI

final class HomePresenter: ObservableObject {
    @Published var viewState = HomeViewState()

    private let interactor: HomeInteractor
    private var cancellables = Set<AnyCancellable>()

    init(interactor: HomeInteractor = HomeInteractor()) {
        self.interactor = interactor
        loadData()

        LanguageManager.shared.$locale
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.loadData() }
            .store(in: &cancellables)
    }

    func loadData() {
        let data = interactor.fetchHomeData()

        viewState = HomeViewState(
            overdueCount: data.stats.overdueCount,
            showOverdueBanner: data.stats.overdueCount > 0,
            stats: mapStats(data.stats),
            weeklyData: mapWeeklyData(data.weeklyActivities),
            decks: mapDecks(data.decks)
        )
    }

    func deleteDeck(id: UUID) {
        viewState.decks.removeAll { $0.id == id }
    }

    // MARK: - Mapping

    private func mapStats(_ stats: HomeStats) -> StatsViewData {
        StatsViewData(
            streakText: "\(stats.streakDays)",
            streakMessage: streakMessage(for: stats.streakDays),
            learnedText: "\(stats.learnedCount)",
            reviewsText: "\(stats.reviewCount)"
        )
    }

    private func streakMessage(for days: Int) -> String {
        let bundle = LanguageManager.shared.bundle
        if days >= 7 {
            return String(localized: "Keep it up !", bundle: bundle)
        } else if days >= 3 {
            return String(localized: "Nice going !", bundle: bundle)
        } else {
            return String(localized: "Let's start !", bundle: bundle)
        }
    }

    private func mapWeeklyData(_ activities: [DayActivity]) -> [DayBarData] {
        activities.map { activity in
            DayBarData(
                dayLabel: activity.dayLabel,
                totalCards: activity.totalCards,
                completedCards: activity.completedCards,
                isToday: activity.isToday
            )
        }
    }

    private func mapDecks(_ decks: [Deck]) -> [DeckViewData] {
        decks.map { deck in
            DeckViewData(
                id: deck.id,
                name: deck.name,
                description: deck.description,
                progress: deck.progress,
                progressPercent: "\(Int(deck.progress * 100))%",
                totalCards: "\(deck.totalCards)",
                dueCards: deck.dueCards,
                estimatedMinutes: deck.estimatedMinutes,
                progressColor: colorForTag(deck.colorTag)
            )
        }
    }

    private func colorForTag(_ tag: ColorTag) -> Color {
        switch tag {
        case .pink: return .streakPink
        case .green: return .learnedGreen
        }
    }
}

import Combine
import SwiftUI
import SwiftData

final class HomePresenter: ObservableObject {
    @Published var viewState = HomeViewState()
    @Published var searchText: String = ""

    private var interactor: HomeInteractor?
    private var allDecks: [DeckViewData] = []
    private var cancellables = Set<AnyCancellable>()

    func configure(modelContext: ModelContext) {
        if interactor != nil {
            loadData()
            return
        }
        self.interactor = HomeInteractor(modelContext: modelContext)

        LanguageManager.shared.$locale
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.loadData() }
            .store(in: &cancellables)

        $searchText
            .dropFirst()
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.applySearch() }
            .store(in: &cancellables)

        loadData()
    }

    func loadData() {
        guard let interactor else { return }
        let data = interactor.fetchHomeData()

        allDecks = mapDecks(data.decks)

        viewState = HomeViewState(
            overdueCount: data.stats.overdueCount,
            firstOverdueDeckID: data.firstOverdueDeckID,
            stats: mapStats(data.stats),
            weeklyData: mapWeeklyData(data.weeklyActivities),
            decks: filteredDecks(),
            isEmpty: data.decks.isEmpty
        )
    }

    func applySearch() {
        viewState.decks = filteredDecks()
    }

    private func filteredDecks() -> [DeckViewData] {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard !query.isEmpty else { return allDecks }
        return allDecks.filter { $0.name.lowercased().contains(query) }
    }

    func deleteDeck(id: UUID) {
        interactor?.deleteDeck(id: id)
        loadData()
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
        if days >= 3 && days < 7 {
            return String(localized: "Nice going !", bundle: bundle)
        } else {
            return String(localized: "Keep it up !", bundle: bundle)
        }
    }

    private func mapWeeklyData(_ activities: [DayActivity]) -> [DayBarData] {
        activities.map { activity in
            DayBarData(
                dayLabel: activity.dayLabel,
                studiedCards: activity.studiedCards,
                isToday: activity.isToday
            )
        }
    }

    private func mapDecks(_ decks: [Deck]) -> [DeckViewData] {
        decks.map { deck in
            DeckViewData(
                id: deck.id,
                name: deck.name,
                description: deck.deckDescription,
                progress: deck.progress,
                progressPercent: "\(Int(deck.progress * 100))%",
                totalCards: "\(deck.totalCards)",
                dueCards: deck.dueCards,
                estimatedMinutes: deck.estimatedMinutes,
                progressColor: Color.colorForTag(deck.colorTagEnum)
            )
        }
    }

}

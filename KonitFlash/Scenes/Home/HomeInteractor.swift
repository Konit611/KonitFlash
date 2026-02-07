import Foundation

struct HomeData {
    let stats: HomeStats
    let weeklyActivities: [DayActivity]
    let decks: [Deck]
}

final class HomeInteractor {
    func fetchHomeData() -> HomeData {
        let stats = HomeStats(
            streakDays: 12,
            learnedCount: 342,
            reviewCount: 1245,
            overdueCount: 45
        )

        let weeklyActivities = [
            DayActivity(dayLabel: "Mon", totalCards: 43, completedCards: 43, isToday: false),
            DayActivity(dayLabel: "Tue", totalCards: 18, completedCards: 6, isToday: false),
            DayActivity(dayLabel: "Wed", totalCards: 21, completedCards: 0, isToday: true),
            DayActivity(dayLabel: "Thu", totalCards: 21, completedCards: 0, isToday: false),
            DayActivity(dayLabel: "Fri", totalCards: 11, completedCards: 0, isToday: false),
            DayActivity(dayLabel: "Sat", totalCards: 52, completedCards: 0, isToday: false),
            DayActivity(dayLabel: "Sun", totalCards: 24, completedCards: 0, isToday: false),
        ]

        let decks = [
            Deck(
                name: "English Vocabulary",
                description: "Essential Words for daily conservation",
                progress: 0.6,
                totalCards: 126,
                dueCards: 17,
                estimatedMinutes: 5,
                colorTag: .pink
            ),
            Deck(
                name: "English Vocabulary",
                description: "Essential Words for daily conservation",
                progress: 0.6,
                totalCards: 126,
                dueCards: 17,
                estimatedMinutes: 5,
                colorTag: .pink
            ),
            Deck(
                name: "English Vocabulary",
                description: "Essential Words for daily conservation",
                progress: 0.6,
                totalCards: 126,
                dueCards: 17,
                estimatedMinutes: 5,
                colorTag: .pink
            ),
        ]

        return HomeData(stats: stats, weeklyActivities: weeklyActivities, decks: decks)
    }
}

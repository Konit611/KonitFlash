import SwiftUI

struct HomeViewState {
    var overdueCount: Int = 0
    var showOverdueBanner: Bool = false
    var firstOverdueDeckID: UUID?
    var stats: StatsViewData = StatsViewData()
    var weeklyData: [DayBarData] = []
    var decks: [DeckViewData] = []
    var isEmpty: Bool = true
}

struct StatsViewData {
    var streakText: String = "0"
    var streakMessage: String = ""
    var learnedText: String = "0"
    var reviewsText: String = "0"
}

struct DayBarData: Identifiable {
    let id = UUID()
    let dayLabel: String
    let studiedCards: Int
    let isToday: Bool
}

struct DeckViewData: Identifiable {
    let id: UUID
    let name: String
    let description: String
    let progress: Double
    let progressPercent: String
    let totalCards: String
    let dueCards: Int
    let estimatedMinutes: Int
    let progressColor: Color
}

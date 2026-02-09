import Foundation
import SwiftData

@Model final class Card {
    var id: UUID = UUID()
    var front: String = ""
    var back: String = ""
    var deck: Deck?
    @Relationship(deleteRule: .cascade, inverse: \StudyLog.card)
    var studyLogs: [StudyLog]?
    var dueDate: Date = Date()
    var interval: Double = 0
    var easeFactor: Double = 2.5
    var repetitions: Int = 0
    var box: Int = 1
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    init(front: String = "", back: String = "", deck: Deck? = nil) {
        self.id = UUID()
        self.front = front
        self.back = back
        self.deck = deck
        self.dueDate = Date()
        self.interval = 0
        self.easeFactor = 2.5
        self.repetitions = 0
        self.box = 1
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

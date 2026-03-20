#if DEBUG
import Foundation
import SwiftData

enum SampleDataService {
    static func populate(into context: ModelContext) {
        // Check if data already exists
        let descriptor = FetchDescriptor<Deck>()
        guard (try? context.fetchCount(descriptor)) == 0 else { return }

        let now = Date()
        let calendar = Calendar.current

        // MARK: - Decks

        let toeic = Deck(name: "TOEIC Vocabulary", deckDescription: "Essential words for TOEIC preparation", colorTag: .pink)
        let kanji = Deck(name: "Japanese N2 Kanji", deckDescription: "Common kanji for JLPT N2 level", colorTag: .green)
        let cs = Deck(name: "CS Interview Prep", deckDescription: "Core computer science concepts for interviews", colorTag: .pink)

        context.insert(toeic)
        context.insert(kanji)
        context.insert(cs)

        // MARK: - TOEIC Cards (20)

        let toeicCards: [(String, String)] = [
            ("Abundant", "Present in great quantity; more than adequate"),
            ("Comply", "To act in accordance with a wish or command"),
            ("Deteriorate", "To become progressively worse"),
            ("Elaborate", "Involving many carefully arranged parts; detailed"),
            ("Fluctuate", "To rise and fall irregularly in number or amount"),
            ("Implement", "To put a decision, plan, or agreement into effect"),
            ("Mandatory", "Required by law or rules; compulsory"),
            ("Negotiate", "To try to reach an agreement through discussion"),
            ("Proficient", "Competent or skilled in doing something"),
            ("Reimburse", "To repay a person who has spent money"),
            ("Subsequent", "Coming after something in time; following"),
            ("Tentative", "Not certain or fixed; provisional"),
            ("Unanimous", "Fully in agreement; of one mind"),
            ("Versatile", "Able to adapt to many different functions"),
            ("Withstand", "To remain undamaged by; resist"),
            ("Acquisition", "The purchase of one company by another"),
            ("Benchmark", "A standard or point of reference for comparison"),
            ("Commodity", "A raw material or agricultural product that can be traded"),
            ("Deficit", "The amount by which something falls short"),
            ("Expedite", "To make an action happen sooner or faster"),
        ]

        for (i, (front, back)) in toeicCards.enumerated() {
            let card = Card(front: front, back: back, deck: toeic)
            assignSRSState(card: card, index: i, totalCount: toeicCards.count, now: now, calendar: calendar)
            context.insert(card)
        }

        // MARK: - Japanese N2 Kanji Cards (15)

        let kanjiCards: [(String, String)] = [
            ("経験 (けいけん)", "Experience — knowledge gained through involvement"),
            ("影響 (えいきょう)", "Influence — the effect one thing has on another"),
            ("環境 (かんきょう)", "Environment — the surrounding conditions"),
            ("比較 (ひかく)", "Comparison — examining similarities and differences"),
            ("責任 (せきにん)", "Responsibility — a duty to deal with something"),
            ("提供 (ていきょう)", "Provision — making something available for use"),
            ("判断 (はんだん)", "Judgment — the ability to make decisions"),
            ("現象 (げんしょう)", "Phenomenon — an observable fact or event"),
            ("維持 (いじ)", "Maintenance — keeping something in its existing state"),
            ("対象 (たいしょう)", "Target — a person or thing aimed at"),
            ("構造 (こうぞう)", "Structure — the arrangement of parts"),
            ("基準 (きじゅん)", "Standard — a level of quality or achievement"),
            ("処理 (しょり)", "Processing — performing operations on data"),
            ("要素 (ようそ)", "Element — a component or part of something"),
            ("傾向 (けいこう)", "Tendency — an inclination toward a particular behavior"),
        ]

        for (i, (front, back)) in kanjiCards.enumerated() {
            let card = Card(front: front, back: back, deck: kanji)
            assignSRSState(card: card, index: i, totalCount: kanjiCards.count, now: now, calendar: calendar)
            context.insert(card)
        }

        // MARK: - CS Interview Cards (15)

        let csCards: [(String, String)] = [
            ("What is Big O notation?", "A mathematical notation describing the upper bound of an algorithm's time or space complexity as input grows"),
            ("Explain a Hash Table", "A data structure mapping keys to values using a hash function for O(1) average lookup time"),
            ("Stack vs Queue", "Stack: LIFO (Last In, First Out)\nQueue: FIFO (First In, First Out)"),
            ("What is a Binary Search Tree?", "A tree where each node's left children are smaller and right children are larger, enabling O(log n) search"),
            ("Explain TCP vs UDP", "TCP: reliable, ordered, connection-based\nUDP: fast, no guarantee of delivery, connectionless"),
            ("What is REST?", "An architectural style using HTTP methods (GET, POST, PUT, DELETE) for stateless client-server communication"),
            ("Explain Database Indexing", "A data structure that improves query speed by allowing the database to find rows without scanning the full table"),
            ("What is a Deadlock?", "When two or more processes are blocked forever, each waiting for the other to release a resource"),
            ("Explain MVC Pattern", "Model: data & logic, View: UI presentation, Controller: handles input and updates Model/View"),
            ("What is Recursion?", "A function that calls itself to solve smaller subproblems until reaching a base case"),
            ("Explain CAP Theorem", "A distributed system can only guarantee two of three: Consistency, Availability, Partition tolerance"),
            ("What is a Linked List?", "A linear data structure where elements are stored in nodes, each pointing to the next node in sequence"),
            ("Explain Merge Sort", "A divide-and-conquer algorithm: split array in half, sort each half, merge sorted halves. O(n log n)"),
            ("What is Docker?", "A platform for building and running applications in lightweight, isolated containers"),
            ("Explain ACID Properties", "Atomicity, Consistency, Isolation, Durability — guarantees for reliable database transactions"),
        ]

        for (i, (front, back)) in csCards.enumerated() {
            let card = Card(front: front, back: back, deck: cs)
            assignSRSState(card: card, index: i, totalCount: csCards.count, now: now, calendar: calendar)
            context.insert(card)
        }

        // MARK: - Study Logs (7 days, ~120 total)

        var logCount = 0

        for dayOffset in 0..<7 {
            guard let dayDate = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }
            let sessionsPerDay = Int.random(in: 15...20)

            for session in 0..<sessionsPerDay {
                guard let studyTime = calendar.date(byAdding: .minute, value: -(session * 3), to: dayDate) else { continue }

                let deckIndex = logCount % 3
                let deck = [toeic, kanji, cs][deckIndex]
                let dummyCard = Card(front: "review", back: "review", deck: deck)
                context.insert(dummyCard)

                // Hide review cards by setting far future due date
                dummyCard.dueDate = calendar.date(byAdding: .year, value: 1, to: now) ?? now
                dummyCard.box = Int.random(in: 3...6)
                dummyCard.interval = Double(dummyCard.box * 3)
                dummyCard.repetitions = dummyCard.box

                let grade = weightedRandomGrade()
                let log = StudyLog(card: dummyCard, grade: grade, elapsedSeconds: Double.random(in: 5...30))
                log.studiedAt = studyTime
                context.insert(log)

                logCount += 1
            }
        }

        try? context.save()
    }

    // MARK: - Helpers

    private static func assignSRSState(card: Card, index: Int, totalCount: Int, now: Date, calendar: Calendar) {
        let ratio = Double(index) / Double(totalCount)

        if ratio < 0.3 {
            // New cards (not yet studied)
            card.box = 0
            card.interval = 0
            card.easeFactor = 2.5
            card.repetitions = 0
            card.dueDate = now
        } else if ratio < 0.6 {
            // Due today
            card.box = Int.random(in: 1...3)
            card.interval = Double(card.box * 2)
            card.easeFactor = Double.random(in: 2.0...2.8)
            card.repetitions = card.box
            card.dueDate = now
        } else {
            // Learned (due in future)
            card.box = Int.random(in: 4...7)
            card.interval = Double(card.box * 5)
            card.easeFactor = Double.random(in: 2.3...3.0)
            card.repetitions = card.box
            card.dueDate = calendar.date(byAdding: .day, value: Int.random(in: 1...14), to: now) ?? now
        }
    }

    private static func weightedRandomGrade() -> Int {
        // Weighted: mostly Good(2) and Easy(3)
        let roll = Int.random(in: 0...9)
        switch roll {
        case 0: return 0       // Again 10%
        case 1...2: return 1   // Hard 20%
        case 3...6: return 2   // Good 40%
        default: return 3      // Easy 30%
        }
    }
}
#endif

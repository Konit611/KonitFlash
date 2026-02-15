import Foundation
import os
import SwiftData

private let logger = Logger(subsystem: "geunil.KonitFlash", category: "CSVImportInteractor")

final class CSVImportInteractor {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchDeckName(deckID: UUID) -> String {
        let descriptor = FetchDescriptor<Deck>(predicate: #Predicate { $0.id == deckID })
        return (try? modelContext.fetch(descriptor).first)?.name ?? ""
    }

    func parseFile(at url: URL) -> CSVParseResult {
        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing { url.stopAccessingSecurityScopedResource() }
        }

        guard let data = try? Data(contentsOf: url),
              let content = String(data: data, encoding: .utf8) else {
            return CSVParseResult(cards: [], skippedRows: 0, errors: ["Could not read file"])
        }

        return CSVParser.parse(content)
    }

    func findDuplicates(in deckID: UUID, fronts: [String]) -> Set<String> {
        let descriptor = FetchDescriptor<Deck>(predicate: #Predicate { $0.id == deckID })
        guard let deck = try? modelContext.fetch(descriptor).first else { return [] }
        let existingFronts = Set((deck.cards ?? []).map { $0.front.lowercased() })
        return Set(fronts.filter { existingFronts.contains($0.lowercased()) })
    }

    func importCards(into deckID: UUID, cards: [(front: String, back: String)], skipDuplicates: Set<String>) -> Int {
        let descriptor = FetchDescriptor<Deck>(predicate: #Predicate { $0.id == deckID })
        guard let deck = try? modelContext.fetch(descriptor).first else { return 0 }

        var imported = 0
        for cardData in cards {
            if skipDuplicates.contains(cardData.front.lowercased()) {
                continue
            }
            let card = Card(front: cardData.front, back: cardData.back, deck: deck)
            modelContext.insert(card)
            imported += 1
        }

        do {
            try modelContext.save()
        } catch {
            logger.error("Failed to save imported cards: \(error)")
        }
        return imported
    }
}

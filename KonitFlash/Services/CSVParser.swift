import Foundation

struct CSVParseResult {
    let cards: [(front: String, back: String)]
    let skippedRows: Int
    let errors: [String]
}

enum CSVParser {
    static func parse(_ content: String) -> CSVParseResult {
        var text = content
        // Remove UTF-8 BOM
        if text.hasPrefix("\u{FEFF}") {
            text.removeFirst()
        }

        let lines = text.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        guard !lines.isEmpty else {
            return CSVParseResult(cards: [], skippedRows: 0, errors: ["File is empty"])
        }

        let delimiter = detectDelimiter(firstLine: lines[0])
        var cards: [(front: String, back: String)] = []
        var skippedRows = 0
        var errors: [String] = []
        let startIndex = isHeaderRow(lines[0], delimiter: delimiter) ? 1 : 0

        for i in startIndex..<lines.count {
            let line = lines[i]
            let fields = parseCSVLine(line, delimiter: delimiter)

            if fields.count < 2 {
                skippedRows += 1
                errors.append("Row \(i + 1): Expected 2 columns, found \(fields.count)")
                continue
            }

            let front = fields[0].trimmingCharacters(in: .whitespaces)
            let back = fields[1].trimmingCharacters(in: .whitespaces)

            if front.isEmpty || back.isEmpty {
                skippedRows += 1
                if front.isEmpty && !back.isEmpty {
                    errors.append("Row \(i + 1): Empty front field")
                } else if !front.isEmpty && back.isEmpty {
                    errors.append("Row \(i + 1): Empty back field")
                }
                continue
            }

            cards.append((front: front, back: back))
        }

        return CSVParseResult(cards: cards, skippedRows: skippedRows, errors: errors)
    }

    // MARK: - Private

    private static func detectDelimiter(firstLine: String) -> Character {
        let tabCount = firstLine.filter { $0 == "\t" }.count
        let commaCount = firstLine.filter { $0 == "," }.count
        return tabCount >= commaCount ? "\t" : ","
    }

    private static func isHeaderRow(_ line: String, delimiter: Character) -> Bool {
        let fields = parseCSVLine(line, delimiter: delimiter)
        let headerKeywords = ["term", "definition", "front", "back", "question", "answer", "word", "meaning"]
        let lowered = fields.map { $0.lowercased().trimmingCharacters(in: .whitespaces) }
        return lowered.contains { headerKeywords.contains($0) }
    }

    private static func parseCSVLine(_ line: String, delimiter: Character) -> [String] {
        var fields: [String] = []
        var current = ""
        var inQuotes = false
        var chars = line.makeIterator()

        while let char = chars.next() {
            if inQuotes {
                if char == "\"" {
                    // Check for escaped quote
                    if let next = chars.next() {
                        if next == "\"" {
                            current.append("\"")
                        } else if next == delimiter {
                            fields.append(current)
                            current = ""
                            inQuotes = false
                        } else {
                            current.append(next)
                            inQuotes = false
                        }
                    } else {
                        inQuotes = false
                    }
                } else {
                    current.append(char)
                }
            } else {
                if char == "\"" {
                    inQuotes = true
                } else if char == delimiter {
                    fields.append(current)
                    current = ""
                } else {
                    current.append(char)
                }
            }
        }

        fields.append(current)
        return fields
    }
}

import Foundation

enum CSVImportPhase {
    case selectFile
    case preview
    case importing
    case done
    case error
}

struct CSVImportViewState {
    var phase: CSVImportPhase = .selectFile
    var deckName: String = ""
    var previewCards: [(front: String, back: String)] = []
    var totalCount: Int = 0
    var skippedCount: Int = 0
    var duplicateCount: Int = 0
    var importedCount: Int = 0
    var errorMessage: String = ""
    var errors: [String] = []
}

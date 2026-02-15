import Foundation

enum CSVImportPhase {
    case selectFile
    case preview
    case importing
    case done
    case error
}

struct PreviewCardData: Identifiable {
    let id: Int
    let front: String
    let back: String
}

struct CSVImportViewState {
    var phase: CSVImportPhase = .selectFile
    var deckName: String = ""
    var previewCards: [PreviewCardData] = []
    var totalCount: Int = 0
    var skippedCount: Int = 0
    var duplicateCount: Int = 0
    var importedCount: Int = 0
    var errorMessage: String = ""
    var errors: [String] = []
}

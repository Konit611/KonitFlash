import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct CSVImportView: View {
    @StateObject private var presenter = CSVImportPresenter()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.modelContext) private var modelContext

    private let deckID: UUID
    @State private var showFilePicker = false
    private var isRegular: Bool { sizeClass == .regular }

    init(deckID: UUID) {
        self.deckID = deckID
    }

    var body: some View {
        ScrollView {
            VStack(spacing: isRegular ? 24 : 16) {
                header
                    .padding(.bottom, isRegular ? 0 : 10)

                Text("to \(presenter.viewState.deckName)")
                    .font(.system(size: isRegular ? 18 : 15))
                    .foregroundStyle(.white.opacity(0.6))

                switch presenter.viewState.phase {
                case .selectFile:
                    selectFileContent
                case .preview:
                    previewContent
                case .importing:
                    importingContent
                case .done:
                    doneContent
                case .error:
                    errorContent
                }
            }
            .padding(.horizontal, isRegular ? 40 : 15)
            .padding(.top, isRegular ? 20 : 10)
        }
        .background(Color.appBackground)
        .navigationBarHidden(true)
        .onAppear { presenter.configure(modelContext: modelContext, deckID: deckID) }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.commaSeparatedText, .tabSeparatedText, .plainText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    presenter.handleFileSelected(url: url)
                }
            case .failure:
                presenter.handleFileError()
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        AppHeaderView(
            title: String(localized: "Import CSV", bundle: LanguageManager.shared.bundle),
            onDismiss: { dismiss() }
        )
    }

    // MARK: - Select File

    private var selectFileContent: some View {
        VStack(spacing: isRegular ? 24 : 18) {
            VStack(spacing: 12) {
                Image(systemName: "doc.text")
                    .font(.system(size: isRegular ? 48 : 36))
                    .foregroundStyle(.white.opacity(0.4))

                Text("Select a CSV or TSV file", bundle: LanguageManager.shared.bundle)
                    .font(.system(size: isRegular ? 20 : 17, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))

                Text("2-column format: Front, Back", bundle: LanguageManager.shared.bundle)
                    .font(.system(size: isRegular ? 15 : 13))
                    .foregroundStyle(.white.opacity(0.4))

                Text("Compatible with NotebookLM exports", bundle: LanguageManager.shared.bundle)
                    .font(.system(size: isRegular ? 15 : 13))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, isRegular ? 48 : 32)

            Button {
                showFilePicker = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "folder")
                        .font(.system(size: 16, weight: .medium))
                    Text("Choose File", bundle: LanguageManager.shared.bundle)
                        .font(.system(size: isRegular ? 18 : 16, weight: .bold))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, isRegular ? 16 : 12)
                .background(Color.learnedGreen, in: RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    // MARK: - Preview

    private var previewContent: some View {
        VStack(spacing: isRegular ? 20 : 14) {
            // Stats
            HStack(spacing: isRegular ? 24 : 16) {
                statBadge(count: "\(presenter.viewState.totalCount)", label: String(localized: "Cards Found", bundle: LanguageManager.shared.bundle))
                if presenter.viewState.skippedCount > 0 {
                    statBadge(count: "\(presenter.viewState.skippedCount)", label: String(localized: "Skipped", bundle: LanguageManager.shared.bundle))
                }
                if presenter.viewState.duplicateCount > 0 {
                    statBadge(count: "\(presenter.viewState.duplicateCount)", label: String(localized: "Duplicates", bundle: LanguageManager.shared.bundle))
                }
            }

            // Preview cards
            VStack(alignment: .leading, spacing: 0) {
                Text("Preview", bundle: LanguageManager.shared.bundle)
                    .font(.system(size: isRegular ? 16 : 14, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.5))
                    .padding(.bottom, 10)

                ForEach(Array(presenter.viewState.previewCards.enumerated()), id: \.offset) { index, card in
                    if index > 0 {
                        Divider()
                    }
                    HStack(alignment: .top) {
                        Text(card.front)
                            .font(.system(size: isRegular ? 16 : 14, weight: .medium))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(card.back)
                            .font(.system(size: isRegular ? 16 : 14))
                            .foregroundStyle(.black.opacity(0.6))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 10)
                }

                if presenter.viewState.totalCount > 5 {
                    Text("... and \(presenter.viewState.totalCount - 5) more", bundle: LanguageManager.shared.bundle)
                        .font(.system(size: isRegular ? 14 : 12))
                        .foregroundStyle(.black.opacity(0.4))
                        .padding(.top, 8)
                }
            }
            .padding(isRegular ? 24 : 18)
            .background(.white, in: RoundedRectangle(cornerRadius: 18))

            // Errors
            if !presenter.viewState.errors.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(presenter.viewState.errors, id: \.self) { error in
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.overdueText)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Buttons
            HStack(spacing: isRegular ? 16 : 12) {
                Button {
                    presenter.resetToFileSelect()
                } label: {
                    Text("Cancel", bundle: LanguageManager.shared.bundle)
                        .font(.system(size: isRegular ? 18 : 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, isRegular ? 16 : 12)
                        .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
                }

                Button {
                    presenter.confirmImport()
                } label: {
                    let newCards = presenter.viewState.totalCount - presenter.viewState.duplicateCount
                    Text("Import \(newCards) Cards", bundle: LanguageManager.shared.bundle)
                        .font(.system(size: isRegular ? 18 : 15, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, isRegular ? 16 : 12)
                        .background(Color.learnedGreen, in: RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }

    // MARK: - Importing

    private var importingContent: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.white)
            Text("Importing cards...", bundle: LanguageManager.shared.bundle)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    // MARK: - Done

    private var doneContent: some View {
        VStack(spacing: isRegular ? 24 : 18) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: isRegular ? 56 : 44))
                .foregroundStyle(Color.learnedGreen)

            Text("\(presenter.viewState.importedCount) cards imported!", bundle: LanguageManager.shared.bundle)
                .font(.system(size: isRegular ? 22 : 18, weight: .bold))
                .foregroundStyle(.white)

            Button {
                dismiss()
            } label: {
                Text("Done", bundle: LanguageManager.shared.bundle)
                    .font(.system(size: isRegular ? 18 : 16, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, isRegular ? 16 : 12)
                    .background(Color.learnedGreen, in: RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(.vertical, 40)
    }

    // MARK: - Error

    private var errorContent: some View {
        VStack(spacing: isRegular ? 20 : 14) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: isRegular ? 48 : 36))
                .foregroundStyle(Color.overdueText)

            Text(presenter.viewState.errorMessage)
                .font(.system(size: isRegular ? 18 : 15))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            Button {
                presenter.resetToFileSelect()
            } label: {
                Text("Try Again", bundle: LanguageManager.shared.bundle)
                    .font(.system(size: isRegular ? 18 : 16, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, isRegular ? 16 : 12)
                    .background(Color.learnedGreen, in: RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(.vertical, 40)
    }

    // MARK: - Helpers

    private func statBadge(count: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(count)
                .font(.system(size: isRegular ? 28 : 22, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: isRegular ? 13 : 11))
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, isRegular ? 16 : 12)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
    }
}

#Preview("iPhone") {
    NavigationStack {
        CSVImportView(deckID: UUID())
    }
    .modelContainer(for: [Deck.self, Card.self, StudyLog.self], inMemory: true)
}

#Preview("Mac") {
    NavigationStack {
        CSVImportView(deckID: UUID())
    }
    .frame(width: 1440, height: 900)
    .modelContainer(for: [Deck.self, Card.self, StudyLog.self], inMemory: true)
}

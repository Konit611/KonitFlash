import SwiftUI
import SwiftData

struct AddCardView: View {
    @StateObject private var presenter = AddCardPresenter()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.modelContext) private var modelContext

    private let deckID: UUID
    private let editingCardID: UUID?
    private var isRegular: Bool { sizeClass == .regular }

    init(deckID: UUID, editingCardID: UUID? = nil) {
        self.deckID = deckID
        self.editingCardID = editingCardID
    }

    var body: some View {
        ScrollView {
            VStack(spacing: isRegular ? 24 : 16) {
                header
                    .padding(.bottom, isRegular ? 0 : 10)

                Text("to \(presenter.viewState.deckName)")
                    .font(.system(size: isRegular ? 18 : 15))
                    .foregroundStyle(.white.opacity(0.6))

                formCard

                addButton
            }
            .padding(.horizontal, isRegular ? 40 : 15)
            .padding(.top, isRegular ? 20 : 10)
        }
        .background(Color.appBackground)
        .navigationBarHidden(true)
        .onAppear { presenter.configure(modelContext: modelContext, deckID: deckID, editingCardID: editingCardID) }
        .onDisappear { WidgetDataService.writeWidgetData(from: modelContext) }
    }

    // MARK: - Header

    private var header: some View {
        AppHeaderView(
            title: presenter.viewState.headerTitle,
            onDismiss: { dismiss() }
        )
    }

    // MARK: - Form Card

    private var formCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            FormTextField(
                label: String(localized: "Front", bundle: LanguageManager.shared.bundle),
                text: Binding(
                    get: { presenter.viewState.front },
                    set: { presenter.updateFront($0) }
                ),
                placeholder: String(localized: "Enter front text", bundle: LanguageManager.shared.bundle)
            )
            .padding(.bottom, isRegular ? 20 : 16)

            Rectangle()
                .fill(Color(hex: 0xE8E8E8))
                .frame(height: 1)
                .padding(.bottom, isRegular ? 20 : 16)

            FormTextEditor(
                label: String(localized: "Back", bundle: LanguageManager.shared.bundle),
                text: Binding(
                    get: { presenter.viewState.back },
                    set: { presenter.updateBack($0) }
                ),
                placeholder: String(localized: "Enter back text", bundle: LanguageManager.shared.bundle)
            )
        }
        .padding(isRegular ? 28 : 20)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Add Button

    private var addButton: some View {
        Button {
            if presenter.viewState.isEditMode {
                presenter.updateCard()
            } else {
                presenter.createCard()
            }
            dismiss()
        } label: {
            Text(presenter.viewState.buttonTitle)
                .font(.system(size: isRegular ? 20 : 17, weight: .bold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, isRegular ? 18 : 14)
                .background(Color.learnedGreen, in: RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!presenter.viewState.isSaveEnabled)
        .opacity(presenter.viewState.isSaveEnabled ? 1 : 0.4)
    }
}

#Preview("iPhone") {
    NavigationStack {
        AddCardView(deckID: UUID())
    }
    .modelContainer(for: [Deck.self, Card.self, StudyLog.self], inMemory: true)
}

#Preview("Mac") {
    NavigationStack {
        AddCardView(deckID: UUID())
    }
    .frame(width: 1440, height: 900)
    .modelContainer(for: [Deck.self, Card.self, StudyLog.self], inMemory: true)
}

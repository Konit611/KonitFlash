import SwiftUI

struct AddDeckView: View {
    @StateObject private var presenter: AddDeckPresenter
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }

    init(editingDeckID: UUID? = nil) {
        _presenter = StateObject(wrappedValue: AddDeckPresenter(editingDeckID: editingDeckID))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: isRegular ? 24 : 16) {
                header
                    .padding(.bottom, isRegular ? 0 : 10)

                formCard

                createButton
            }
            .padding(.horizontal, isRegular ? 40 : 15)
            .padding(.top, isRegular ? 20 : 10)
        }
        .background(Color.appBackground)
        .navigationBarHidden(true)
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
        VStack(alignment: .leading, spacing: isRegular ? 24 : 18) {
            FormFieldView(
                label: "Deck Name",
                text: Binding(
                    get: { presenter.viewState.name },
                    set: { presenter.updateName($0) }
                )
            )

            FormFieldView(
                label: "Description",
                text: Binding(
                    get: { presenter.viewState.description },
                    set: { presenter.updateDescription($0) }
                )
            )

            ColorTagPicker(
                selectedTag: Binding(
                    get: { presenter.viewState.selectedColorTag },
                    set: { presenter.updateColorTag($0) }
                )
            )
        }
        .padding(isRegular ? 28 : 20)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Create Button

    private var createButton: some View {
        Button {
            presenter.saveDeck()
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
        AddDeckView()
    }
}

#Preview("Mac") {
    NavigationStack {
        AddDeckView()
    }
    .frame(width: 1440, height: 900)
}

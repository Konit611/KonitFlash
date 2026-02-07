import SwiftUI

struct FormFieldView: View {
    let label: String
    @Binding var text: String
    var isMultiline: Bool = false
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }

    var body: some View {
        VStack(alignment: .leading, spacing: isRegular ? 10 : 8) {
            Text(label)
                .font(.system(size: isRegular ? 20 : 16, weight: .semibold))
                .foregroundStyle(Color(hex: 0x555555))

            if isMultiline {
                TextEditor(text: $text)
                    .font(.system(size: isRegular ? 20 : 16))
                    .foregroundStyle(.black)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: isRegular ? 120 : 80)
            } else {
                TextField("", text: $text)
                    .font(.system(size: isRegular ? 20 : 16))
                    .foregroundStyle(.black)
            }
        }
    }
}

#Preview("iPhone") {
    FormFieldView(label: "Deck Name", text: .constant("English Vocabulary"))
        .padding()
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
        .padding()
        .background(Color.appBackground)
}

#Preview("Mac") {
    FormFieldView(label: "Deck Name", text: .constant("English Vocabulary"))
        .padding()
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
        .padding(40)
        .frame(width: 700)
        .background(Color.appBackground)
}

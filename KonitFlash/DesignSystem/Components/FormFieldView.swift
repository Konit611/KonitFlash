import SwiftUI

struct FormTextField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }

    var body: some View {
        VStack(alignment: .leading, spacing: isRegular ? 10 : 8) {
            Text(label)
                .font(.system(size: isRegular ? 20 : 16, weight: .semibold))
                .foregroundStyle(Color(hex: 0x555555))

            TextField(placeholder, text: $text)
                .font(.system(size: isRegular ? 20 : 16))
                .foregroundStyle(.black)
                .padding(.horizontal, isRegular ? 16 : 12)
                .padding(.vertical, isRegular ? 14 : 10)
                .background(Color(hex: 0xF5F5F5), in: RoundedRectangle(cornerRadius: isRegular ? 12 : 10))
        }
    }
}

struct FormTextEditor: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }

    var body: some View {
        VStack(alignment: .leading, spacing: isRegular ? 10 : 8) {
            Text(label)
                .font(.system(size: isRegular ? 20 : 16, weight: .semibold))
                .foregroundStyle(Color(hex: 0x555555))

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: isRegular ? 20 : 16))
                        .foregroundStyle(Color(hex: 0xBBBBBB))
                        .padding(.horizontal, isRegular ? 16 : 12)
                        .padding(.vertical, isRegular ? 14 : 10)
                }
                TextEditor(text: $text)
                    .font(.system(size: isRegular ? 20 : 16))
                    .foregroundStyle(.black)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, isRegular ? 11 : 7)
                    .padding(.vertical, isRegular ? 6 : 2)
            }
            .frame(minHeight: isRegular ? 140 : 100)
            .background(Color(hex: 0xF5F5F5), in: RoundedRectangle(cornerRadius: isRegular ? 12 : 10))
        }
    }
}

#Preview("iPhone") {
    VStack(spacing: 20) {
        FormTextField(label: "Deck Name", text: .constant(""), placeholder: "Enter deck name")
        FormTextField(label: "Deck Name", text: .constant("English Vocabulary"), placeholder: "Enter deck name")
        FormTextEditor(label: "Description", text: .constant(""), placeholder: "Enter description")
    }
    .padding()
    .background(.white, in: RoundedRectangle(cornerRadius: 18))
    .padding()
    .background(Color.appBackground)
}

#Preview("Mac") {
    VStack(spacing: 20) {
        FormTextField(label: "Deck Name", text: .constant(""), placeholder: "Enter deck name")
        FormTextEditor(label: "Description", text: .constant(""), placeholder: "Enter description")
    }
    .padding()
    .background(.white, in: RoundedRectangle(cornerRadius: 18))
    .padding(40)
    .frame(width: 700)
    .background(Color.appBackground)
}

import SwiftUI

struct ColorTagPicker: View {
    @Binding var selectedTag: ColorTag
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }

    private var tagOptions: [(ColorTag, Color)] {
        [(.pink, .streakPink), (.green, .learnedGreen)]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: isRegular ? 10 : 8) {
            Text("Color", bundle: LanguageManager.shared.bundle)
                .font(.system(size: isRegular ? 20 : 16, weight: .semibold))
                .foregroundStyle(Color(hex: 0x555555))

            HStack(spacing: isRegular ? 16 : 12) {
                ForEach(tagOptions, id: \.0) { tag, color in
                    Circle()
                        .fill(color)
                        .frame(
                            width: isRegular ? 44 : 36,
                            height: isRegular ? 44 : 36
                        )
                        .overlay {
                            if selectedTag == tag {
                                Circle()
                                    .stroke(.black, lineWidth: 3)
                                    .padding(2)
                            }
                        }
                        .onTapGesture {
                            selectedTag = tag
                        }
                }
            }
        }
    }
}

#Preview("iPhone") {
    ColorTagPicker(selectedTag: .constant(.pink))
        .padding()
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
        .padding()
        .background(Color.appBackground)
}

#Preview("Mac") {
    ColorTagPicker(selectedTag: .constant(.green))
        .padding()
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
        .padding(40)
        .frame(width: 700)
        .background(Color.appBackground)
}

import SwiftUI

struct SettingsView: View {
    @StateObject private var presenter = SettingsPresenter()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.modelContext) private var modelContext

    @State private var showLanguagePicker = false
    @State private var showAcknowledgments = false
    @State private var customLimitText = ""
    @FocusState private var isCustomFieldFocused: Bool

    private var isRegular: Bool { sizeClass == .regular }

    var body: some View {
        ScrollView {
            VStack(spacing: isRegular ? 32 : 24) {
                header
                    .padding(.bottom, isRegular ? 0 : 2)

                // Preferences group
                VStack(spacing: isRegular ? 24 : 16) {
                    languageSection
                    sessionCardLimitSection
                }

                // About group
                appInfoSection
            }
            .frame(maxWidth: isRegular ? 600 : .infinity)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, isRegular ? 40 : 15)
            .padding(.top, isRegular ? 20 : 10)
            .padding(.bottom, 40)
        }
        .background(Color.appBackground)
        .navigationBarHidden(true)
        .onAppear { presenter.configure() }
        .sheet(isPresented: $showLanguagePicker) {
            languagePickerSheet
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showAcknowledgments) {
            acknowledgmentsSheet
        }
    }

    // MARK: - Header

    private var header: some View {
        AppHeaderView(
            title: String(localized: "Settings", bundle: LanguageManager.shared.bundle),
            onDismiss: { dismiss() }
        )
    }

    // MARK: - Language Section

    private var selectedLanguageName: String {
        presenter.viewState.languages.first(where: \.isSelected)?.name ?? ""
    }

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: isRegular ? 20 : 14) {
            Text(String(localized: "Language", bundle: LanguageManager.shared.bundle))
                .font(.system(size: isRegular ? 18 : 15, weight: .semibold))
                .foregroundStyle(.white.opacity(0.6))

            Button {
                showLanguagePicker = true
            } label: {
                HStack {
                    Text(selectedLanguageName)
                        .font(.system(size: isRegular ? 18 : 16))
                        .foregroundStyle(.black)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: isRegular ? 14 : 12, weight: .semibold))
                        .foregroundStyle(Color(hex: 0xCCCCCC))
                }
                .padding(.horizontal, isRegular ? 24 : 18)
                .padding(.vertical, isRegular ? 18 : 14)
            }
            .background(.white, in: RoundedRectangle(cornerRadius: 18))
        }
    }

    private var languagePickerSheet: some View {
        let bundle = LanguageManager.shared.bundle

        return NavigationStack {
            List {
                ForEach(presenter.viewState.languages) { language in
                    Button {
                        presenter.selectLanguage(language.id)
                        WidgetDataService.writeWidgetData(from: modelContext)
                    } label: {
                        HStack {
                            Text(language.name)
                                .font(.system(size: isRegular ? 18 : 16))
                                .foregroundStyle(.primary)

                            Spacer()

                            if language.isSelected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: isRegular ? 16 : 14, weight: .semibold))
                                    .foregroundStyle(Color.learnedGreen)
                            }
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityAddTraits(language.isSelected ? .isSelected : [])
                    }
                }
            }
            .navigationTitle(String(localized: "Language", bundle: bundle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "Done", bundle: bundle)) {
                        showLanguagePicker = false
                    }
                }
            }
        }
    }

    // MARK: - Session Card Limit Section (Preset Chips)

    private var sessionCardLimitSection: some View {
        let bundle = LanguageManager.shared.bundle
        let isCustom = presenter.viewState.isCustomSelected

        return VStack(alignment: .leading, spacing: isRegular ? 20 : 14) {
            Text(String(localized: "Cards per Session", bundle: bundle))
                .font(.system(size: isRegular ? 18 : 15, weight: .semibold))
                .foregroundStyle(.white.opacity(0.6))

            VStack(alignment: .leading, spacing: isRegular ? 16 : 12) {
                // Preset chips row (wrapping)
                FlowLayout(spacing: 8) {
                    ForEach(presenter.viewState.presetLimits) { preset in
                        chipButton(
                            label: preset.label,
                            isSelected: preset.isSelected,
                            accessibilityLabel: preset.id == 0
                                ? String(localized: "Unlimited", bundle: bundle)
                                : String(localized: "\(preset.id) cards per session", bundle: bundle)
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                presenter.selectPresetLimit(preset.id)
                            }
                            isCustomFieldFocused = false
                        }
                    }

                    // Custom chip
                    chipButton(
                        label: String(localized: "Custom", bundle: bundle),
                        isSelected: isCustom,
                        accessibilityLabel: String(localized: "Custom card limit", bundle: bundle)
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            presenter.selectCustom()
                        }
                        customLimitText = presenter.viewState.customLimitText
                        isCustomFieldFocused = true
                    }
                }

                // Custom input — always visible, enabled only when Custom is selected
                HStack(spacing: 12) {
                    TextField(
                        String(localized: "Enter number", bundle: bundle),
                        text: $customLimitText
                    )
                    .keyboardType(.numberPad)
                    .font(.system(size: isRegular ? 18 : 16, weight: .medium))
                    .foregroundStyle(isCustom ? .black : Color(hex: 0xBBBBBB))
                    .padding(.horizontal, isRegular ? 20 : 16)
                    .padding(.vertical, isRegular ? 14 : 10)
                    .background(
                        Color(hex: 0xF5F5F5),
                        in: RoundedRectangle(cornerRadius: 12)
                    )
                    .focused($isCustomFieldFocused)
                    .disabled(!isCustom)
                    .onChange(of: customLimitText) { _, newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered != newValue {
                            customLimitText = filtered
                        }
                    }
                    .onSubmit {
                        presenter.setCustomLimit(customLimitText)
                    }
                    .accessibilityLabel(String(localized: "Custom card count", bundle: bundle))

                    Button {
                        presenter.setCustomLimit(customLimitText)
                        isCustomFieldFocused = false
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: isRegular ? 16 : 14, weight: .bold))
                            .foregroundStyle(isCustom ? .black : Color(hex: 0xBBBBBB))
                            .frame(width: isRegular ? 44 : 38, height: isRegular ? 44 : 38)
                            .background(
                                isCustom ? Color.learnedGreen : Color(hex: 0xEEEEEE),
                                in: RoundedRectangle(cornerRadius: 12)
                            )
                    }
                    .disabled(!isCustom)
                    .accessibilityLabel(String(localized: "Apply custom limit", bundle: bundle))
                }
                .opacity(isCustom ? 1 : 0.35)
                .animation(.easeInOut(duration: 0.2), value: isCustom)
            }
            .padding(.horizontal, isRegular ? 24 : 18)
            .padding(.vertical, isRegular ? 18 : 14)
            .background(.white, in: RoundedRectangle(cornerRadius: 18))
        }
    }

    private func chipButton(
        label: String,
        isSelected: Bool,
        accessibilityLabel: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: isRegular ? 16 : 14, weight: .semibold))
                .foregroundStyle(isSelected ? .black : Color(hex: 0x666666))
                .padding(.horizontal, isRegular ? 18 : 14)
                .padding(.vertical, isRegular ? 10 : 8)
                .background(
                    isSelected ? Color.learnedGreen : .clear,
                    in: RoundedRectangle(cornerRadius: 20)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color(hex: 0xDDDDDD), lineWidth: 1)
                )
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .accessibilityLabel(accessibilityLabel ?? label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - App Info Section

    private var appInfoSection: some View {
        let bundle = LanguageManager.shared.bundle

        return VStack(alignment: .leading, spacing: isRegular ? 20 : 14) {
            Text(String(localized: "App Info", bundle: bundle))
                .font(.system(size: isRegular ? 18 : 15, weight: .semibold))
                .foregroundStyle(.white.opacity(0.6))

            VStack(spacing: 0) {
                // Version row
                infoRow(
                    icon: "info.circle",
                    title: String(localized: "Version", bundle: bundle),
                    trailing: {
                        Text("\(presenter.viewState.appVersion) (\(presenter.viewState.buildNumber))")
                            .font(.system(size: isRegular ? 16 : 14))
                            .foregroundStyle(Color(hex: 0x999999))
                    }
                )

                Divider()
                    .padding(.horizontal, isRegular ? 24 : 18)

                // Privacy Policy row
                Link(destination: presenter.viewState.privacyPolicyURL) {
                    infoRowContent(
                        icon: "hand.raised",
                        title: String(localized: "Privacy Policy", bundle: bundle),
                        showChevron: true
                    )
                }

                Divider()
                    .padding(.horizontal, isRegular ? 24 : 18)

                // Acknowledgments row
                Button {
                    showAcknowledgments = true
                } label: {
                    infoRowContent(
                        icon: "heart",
                        title: String(localized: "Acknowledgments", bundle: bundle),
                        showChevron: true
                    )
                }
            }
            .background(.white, in: RoundedRectangle(cornerRadius: 18))
        }
    }

    private func infoRow<Trailing: View>(
        icon: String,
        title: String,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack(spacing: isRegular ? 14 : 10) {
            Image(systemName: icon)
                .font(.system(size: isRegular ? 18 : 16))
                .foregroundStyle(Color(hex: 0x999999))
                .frame(width: isRegular ? 24 : 20)

            Text(title)
                .font(.system(size: isRegular ? 18 : 16))
                .foregroundStyle(.black)

            Spacer()

            trailing()
        }
        .padding(.horizontal, isRegular ? 24 : 18)
        .padding(.vertical, isRegular ? 18 : 14)
    }

    private func infoRowContent(icon: String, title: String, showChevron: Bool) -> some View {
        HStack(spacing: isRegular ? 14 : 10) {
            Image(systemName: icon)
                .font(.system(size: isRegular ? 18 : 16))
                .foregroundStyle(Color(hex: 0x999999))
                .frame(width: isRegular ? 24 : 20)

            Text(title)
                .font(.system(size: isRegular ? 18 : 16))
                .foregroundStyle(.black)

            Spacer()

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: isRegular ? 14 : 12, weight: .semibold))
                    .foregroundStyle(Color(hex: 0xCCCCCC))
            }
        }
        .padding(.horizontal, isRegular ? 24 : 18)
        .padding(.vertical, isRegular ? 18 : 14)
    }

    // MARK: - Acknowledgments Sheet

    private var acknowledgmentsSheet: some View {
        let bundle = LanguageManager.shared.bundle
        let libraries: [(name: String, author: String, description: String, url: String)] = [
            ("LaTeXSwiftUI", "colinc86", String(localized: "LaTeX rendering for SwiftUI", bundle: bundle), "https://github.com/colinc86/LaTeXSwiftUI"),
            ("MathJaxSwift", "colinc86", String(localized: "MathJax engine for Swift", bundle: bundle), "https://github.com/colinc86/MathJaxSwift"),
            ("swift-html-entities", "Kitura", String(localized: "HTML entity encoding/decoding", bundle: bundle), "https://github.com/Kitura/swift-html-entities"),
            ("SwiftDraw", "swhitty", String(localized: "SVG rendering for Swift", bundle: bundle), "https://github.com/swhitty/SwiftDraw")
        ]

        return NavigationStack {
            List {
                ForEach(libraries, id: \.name) { lib in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(lib.name)
                                .font(.system(size: isRegular ? 18 : 16, weight: .semibold))

                            Spacer()

                            Text(lib.author)
                                .font(.system(size: isRegular ? 14 : 12))
                                .foregroundStyle(.secondary)
                        }

                        Text(lib.description)
                            .font(.system(size: isRegular ? 14 : 13))
                            .foregroundStyle(.secondary)

                        if let url = URL(string: lib.url) {
                            Link(lib.url, destination: url)
                                .font(.system(size: isRegular ? 13 : 12))
                                .foregroundStyle(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(String(localized: "Acknowledgments", bundle: bundle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "Done", bundle: bundle)) {
                        showAcknowledgments = false
                    }
                }
            }
        }
    }
}

// MARK: - FlowLayout (Wrapping Horizontal Layout)

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX - spacing)
        }

        return (
            size: CGSize(width: totalWidth, height: currentY + lineHeight),
            positions: positions
        )
    }
}

#Preview("iPhone") {
    NavigationStack {
        SettingsView()
    }
}

#Preview("Mac") {
    NavigationStack {
        SettingsView()
    }
    .frame(width: 1440, height: 900)
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// ExchangeSellButton from the Figma Component Library.
///
///
/// # Usage:
///
/// `ExchangeSellButton(title: "Tap me") { print("button did tap") }`
///
/// - Version: 1.0.1
///
/// # Figma
///
///  [Buttons](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=3%3A367)

public struct ExchangeSellButton: View {

    private let title: String
    private let action: () -> Void
    private let isLoading: Bool

    private let colorCombination = PillButtonStyle.ColorCombination(
        enabled: PillButtonStyle.ColorSet(
            foreground: Color.dynamicColor(
                light: .semantic.white,
                dark: .semantic.white
            ),
            background: Color.dynamicColor(
                light: .semantic.error,
                dark: .semantic.errorMuted
            ),
            border: Color.dynamicColor(
                light: .semantic.error,
                dark: .semantic.errorMuted
            )
        ),
        pressed: PillButtonStyle.ColorSet(
            foreground: .semantic.white,
            background: .semantic.error,
            border: .semantic.error
        ),
        disabled: PillButtonStyle.ColorSet(
            foreground: Color.dynamicColor(
                light: .semantic.white.opacity(0.7),
                dark: .semantic.white.opacity(0.4)
            ),
            background: Color.dynamicColor(
                light: .semantic.errorMuted,
                dark: .semantic.error
            ),
            border: Color.dynamicColor(
                light: .semantic.errorMuted,
                dark: .semantic.error
            )
        ),
        progressViewRail: Color.semantic.white.opacity(0.8),
        progressViewTrack: Color.semantic.white.opacity(0.25)
    )

    public init(
        title: String,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(title) {
            action()
        }
        .buttonStyle(
            PillButtonStyle(
                isLoading: isLoading,
                colorCombination: colorCombination
            )
        )
    }
}

struct ExchangeSellButton_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            ExchangeSellButton(title: "Enabled", action: {})
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Enabled")

            ExchangeSellButton(title: "Disabled", action: {})
                .disabled(true)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Disabled")

            ExchangeSellButton(title: "Loading", isLoading: true, action: {})
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Loading")
        }
        .padding()
    }
}

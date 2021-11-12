// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// MinimalButton from the Figma Component Library.
///
///
/// # Usage:
///
/// `MinimalButton(title: "Tap me") { print("button did tap") }`
///
/// - Version: 1.0.1
///
/// # Figma
///
///  [Buttons](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=3%3A367)

public struct MinimalButton: View {

    private let title: String
    private let action: () -> Void
    private let isLoading: Bool

    @Environment(\.pillButtonSize) private var size

    private let colorCombination = PillButtonStyle.ColorCombination(
        enabled: PillButtonStyle.ColorSet(
            foreground: .semantic.primary,
            background: .semantic.background.opacity(0),
            border: Color(
                light: .semantic.medium,
                dark: .palette.dark300
            )
        ),
        pressed: PillButtonStyle.ColorSet(
            foreground: .semantic.primary,
            background: .semantic.light,
            border: .semantic.primary
        ),
        disabled: PillButtonStyle.ColorSet(
            foreground: Color(
                light: .semantic.primary.opacity(0.7),
                dark: .palette.grey600
            ),
            background: .semantic.background.opacity(0),
            border: Color(
                light: .semantic.light,
                dark: .palette.grey700
            )
        ),
        progressViewRail: .semantic.primary,
        progressViewTrack: Color(
            light: .semantic.blueBG,
            dark: .palette.white.opacity(0.25)
        )
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
                size: size,
                colorCombination: colorCombination
            )
        )
    }
}

struct MinimalButton_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            MinimalButton(title: "Enabled", action: {})
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Enabled")

            MinimalButton(title: "Disabled", action: {})
                .disabled(true)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Disabled")

            MinimalButton(title: "Loading", isLoading: true, action: {})
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Loading")
        }
        .padding()
    }
}

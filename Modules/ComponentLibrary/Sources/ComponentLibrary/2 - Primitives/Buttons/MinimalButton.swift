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

    private let colorCombination = PillButtonStyle.ColorCombination(
        enabled: PillButtonStyle.ColorSet(
            foreground: Color.dynamicColor(
                light: .semantic.primary,
                dark: .semantic.primaryMuted
            ),
            background: .semantic.white.opacity(0),
            border: Color.dynamicColor(
                light: .semantic.medium,
                dark: .semantic.body
            )
        ),
        pressed: PillButtonStyle.ColorSet(
            foreground: Color.dynamicColor(
                light: .semantic.primary,
                dark: .semantic.primaryMuted
            ),
            background: Color.dynamicColor(
                light: .semantic.light,
                dark: .semantic.dark
            ),
            border: Color.dynamicColor(
                light: .semantic.primary,
                dark: .semantic.primaryMuted
            )
        ),
        disabled: PillButtonStyle.ColorSet(
            foreground: Color.dynamicColor(
                light: .semantic.primary.opacity(0.4),
                dark: .semantic.body
            ),
            background: .semantic.white.opacity(0),
            border: Color.dynamicColor(
                light: .semantic.light,
                dark: .semantic.body
            )
        ),
        progressViewRail: Color.dynamicColor(
            light: .semantic.primary,
            dark: .semantic.primaryMuted
        ),
        progressViewTrack: Color.dynamicColor(
            light: .semantic.primaryMuted,
            dark: .semantic.white.opacity(0.25)
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

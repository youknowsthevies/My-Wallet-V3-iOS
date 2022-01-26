// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// DestructivePrimaryButton from the Figma Component Library.
///
///
/// # Usage:
///
/// `DestructivePrimaryButton(title: "Tap me") { print("button did tap") }`
///
/// - Version: 1.0.1
///
/// # Figma
///
///  [Buttons](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=3%3A367)

public struct DestructivePrimaryButton: View {

    private let title: String
    private let action: () -> Void
    private let isLoading: Bool

    @Environment(\.isEnabled) private var isEnabled

    private let colorCombination = PillButtonStyle.ColorCombination(
        enabled: PillButtonStyle.ColorSet(
            foreground: .palette.white,
            background: .semantic.error,
            border: .semantic.error
        ),
        pressed: PillButtonStyle.ColorSet(
            foreground: .palette.white,
            background: Color(
                light: .palette.red700,
                dark: .palette.red600
            ),
            border: Color(
                light: .palette.red700,
                dark: .palette.red600
            )
        ),
        disabled: PillButtonStyle.ColorSet(
            foreground: Color(
                light: .palette.white.opacity(0.7),
                dark: .palette.white.opacity(0.7)
            ),
            background: Color(
                light: .palette.red400,
                dark: .palette.red600
            ),
            border: Color(
                light: .palette.red400,
                dark: .palette.red600
            )
        ),
        progressViewRail: .palette.white.opacity(0.8),
        progressViewTrack: .palette.white.opacity(0.25)
    )

    /// Create a DestructivePrimary Button
    /// - Parameters:
    ///   - title: Title of the button
    ///   - isLoading: Bool to show a progress view instead of the button title
    ///   - action: Action to execute on button tap
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
                isEnabled: isEnabled,
                size: .standard,
                colorCombination: colorCombination
            )
        )
    }
}

struct DestructivePrimaryButton_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            DestructivePrimaryButton(title: "Enabled", action: {})
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Enabled")

            DestructivePrimaryButton(title: "Disabled", action: {})
                .disabled(true)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Disabled")

            DestructivePrimaryButton(title: "Loading", isLoading: true, action: {})
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Loading")
        }
        .padding()
    }
}

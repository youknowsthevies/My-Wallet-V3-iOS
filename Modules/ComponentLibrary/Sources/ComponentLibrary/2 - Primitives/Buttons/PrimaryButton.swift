// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// PrimaryButton from the Figma Component Library.
///
///
/// # Usage:
///
/// `PrimaryButton(title: "Tap me") { print("button did tap") }`
///
/// - Version: 1.0.1
///
/// # Figma
///
///  [Buttons](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=3%3A367)
public struct PrimaryButton: View {

    private let title: String
    private let action: () -> Void
    private let isLoading: Bool

    @Environment(\.pillButtonSize) private var size

    static let colorCombination = PillButtonStyle.ColorCombination(
        enabled: PillButtonStyle.ColorSet(
            foreground: .palette.white,
            background: .palette.blue600,
            border: .palette.blue600
        ),
        pressed: PillButtonStyle.ColorSet(
            foreground: .palette.white,
            background: .palette.blue700,
            border: .palette.blue700
        ),
        disabled: PillButtonStyle.ColorSet(
            foreground: Color(
                light: .palette.white.opacity(0.7),
                dark: .palette.white.opacity(0.4)
            ),
            background: Color(
                light: .palette.blue400,
                dark: .palette.grey900
            ),
            border: Color(
                light: .palette.blue400,
                dark: .palette.grey900
            )
        ),
        progressViewRail: .palette.white.opacity(0.8),
        progressViewTrack: .palette.white.opacity(0.25)
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
                colorCombination: Self.colorCombination
            )
        )
    }
}

struct PrimaryButton_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            PrimaryButton(title: "Enabled", action: {})
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Enabled")

            PrimaryButton(title: "Disabled", action: {})
                .disabled(true)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Disabled")

            PrimaryButton(title: "Loading", isLoading: true, action: {})
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Loading")
        }
        .padding()
    }
}

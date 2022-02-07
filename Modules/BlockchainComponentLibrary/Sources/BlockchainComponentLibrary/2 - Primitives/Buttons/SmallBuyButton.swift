// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// SmallBuyButton from the Figma Component Library.
///
///
/// # Usage:
///
/// `SmallBuyButton(title: "Tap me") { print("button did tap") }`
///
/// - Version: 1.0.1
///
/// # Figma
///
///  [Buttons](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=3%3A367)
public struct SmallBuyButton: View {

    private let title: String
    private let action: () -> Void
    private let isLoading: Bool

    @Environment(\.isEnabled) private var isEnabled

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
                size: .small,
                colorCombination: .buyButtonColorCombination
            )
        )
    }
}

struct SmallBuyButton_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            SmallBuyButton(title: "Enabled", action: {})
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Enabled")

            SmallBuyButton(title: "Disabled", action: {})
                .disabled(true)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Disabled")

            SmallBuyButton(title: "Loading", isLoading: true, action: {})
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Loading")
        }
        .padding()
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// PrimaryWhiteButton used in Referal Welcome
///
///
/// # Usage:
///
/// `PrimaryWhiteButton(title: "Tap me") { print("button did tap") }`
///
/// - Version: 1.0.1
///

public struct PrimaryWhiteButton: View {

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
                size: .standard,
                colorCombination: .referButtonColorCombination
            )
        )
    }
}

struct PrimaryWhiteButton_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            BuyButton(title: "Enabled", action: {})
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Enabled")

            BuyButton(title: "Disabled", action: {})
                .disabled(true)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Disabled")

            BuyButton(title: "Loading", isLoading: true, action: {})
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Loading")
        }
        .padding()
    }
}

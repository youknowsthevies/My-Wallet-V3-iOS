// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// Syntactic suguar on PrimaryButton to render it in a small size
///
/// # Usage
/// ```
/// SmallPrimaryButton(title: "OK") { print("Tapped") }
/// ```
///
/// # Figma
///  [Buttons](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=6%3A2955)
public struct SmallPrimaryButton: View {

    private let title: String
    private let isLoading: Bool
    private let action: () -> Void

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
        PrimaryButton(title: title, isLoading: isLoading, action: action)
            .pillButtonSize(.small)
    }
}

struct SmallPrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SmallPrimaryButton(title: "OK", isLoading: false) {
                print("Tapped")
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Enabled")

            SmallPrimaryButton(title: "OK", isLoading: false) {
                print("Tapped")
            }
            .disabled(true)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Disabled")

            SmallPrimaryButton(title: "OK", isLoading: true) {
                print("Tapped")
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Loading")
        }
    }
}

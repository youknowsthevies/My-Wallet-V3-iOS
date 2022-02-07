// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// A visual element used to separate other content.
///
/// When contained in a stack, the divider extends across the minor axis of the stack, or horizontally when not in a stack.
/// Identical behaviour to SwiftUI's native `Divider`.
///
/// # Figma
///
/// [PrimaryDivider](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=364%3A9676)
public struct PrimaryDivider: View {
    public init() {}

    public var body: some View {
        Divider()
            .background(
                Color(
                    light: .semantic.light,
                    dark: .palette.dark700
                )
            )
    }
}

struct PrimaryDivider_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PrimaryDivider()
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Horizontal")

        HStack {
            PrimaryDivider()
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Vertical")
    }
}

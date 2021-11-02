// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

// MARK: - Public

/// A button displaying an icon inset within a filled circle. Commonly used as navigation items.
///
/// # Usage
///
///   .navigationBarItems(trailing: CircularIconButton(icon: .chevronLeft) { back() })
///
/// # Figma
///
/// [CircularIconButton](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=209%3A1830)
public struct CircularIconButton: View {
    let icon: Icon
    let action: () -> Void

    public init(
        icon: Icon,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ImageViewRepresentable(image: icon.uiImage?.circled, renderingMode: icon.renderingMode)
        }
        .buttonStyle(IconButtonStyle())
    }
}

// MARK: - Previews

struct CircularIconButton_Previews: PreviewProvider {
    static var previews: some View {
        PreviewContainer()
    }

    struct PreviewContainer: View {
        @State var toggle: Bool = false

        var body: some View {
            NavigationView {
                Text(toggle ? "Bar" : "Foo")
                    .navigationBarItems(trailing: navigationItems)
            }
        }

        @ViewBuilder private var navigationItems: some View {
            CircularIconButton(icon: .chevronLeft) {
                toggle.toggle()
            }
        }
    }
}

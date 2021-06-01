// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// A `Button` replacement that can hide to show a loading indicator instead of the main button's content.
public struct LoadingButton: View {

    let title: String
    let icon: Image?
    let action: () -> Void
    @Binding var loading: Bool

    public init(title: String, icon: Image? = nil, action: @escaping () -> Void, loading: Binding<Bool> = .constant(false)) {
        self.title = title
        self.icon = icon
        self._loading = loading
        self.action = action
    }

    public var body: some View {
        if loading {
            ActivityIndicatorView()
                .frame(minHeight: LayoutConstants.buttonMinHeight)
        } else {
            if icon != nil {
                Button(action: action, label: {
                    HStack(spacing: 12) {
                        icon?
                            .renderingMode(.template)
                            .frame(width: 15, height: 15)
                        Text(title)
                    }
                })
            } else {
                Button(title, action: action)
            }
        }
    }
}

#if DEBUG
struct LoadingButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            LoadingButton(title: "Test", action: {}, loading: .constant(false))
            Divider()
            LoadingButton(title: "Test", action: {}, loading: .constant(true))
        }
        .padding()
    }
}
#endif

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public struct IconButtonStyle: ButtonStyle {

    let isEnabled: Bool

    public init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font(weight: .semibold, size: 16))
            .frame(maxWidth: .infinity, minHeight: LayoutConstants.buttonMinHeight)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: LayoutConstants.buttonCornerRadious)
                    .fill(Color.buttonSecondaryBackground)
            )
            .background(
                RoundedRectangle(cornerRadius: LayoutConstants.buttonCornerRadious)
                    .stroke(Color.borderPrimary)
            )
            .opacity(isEnabled ? 1.0 : 0.5)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

public struct IconButton: View {

    let title: String
    let icon: Image
    let action: () -> Void
    @Binding var loading: Bool
    @Environment(\.isEnabled) var isEnabled

    public init(title: String, icon: Image, action: @escaping () -> Void, loading: Binding<Bool> = .constant(false)) {
        self.title = title
        self.icon = icon
        self._loading = loading
        self.action = action
    }

    public var body: some View {
        LoadingButton(title: title, icon: icon, action: action, loading: $loading)
            .buttonStyle(IconButtonStyle(isEnabled: isEnabled))
    }
}

#if DEBUG
struct IconButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Idle")
                    .font(.headline)
                IconButton(title: "Test", icon: Image(systemName: "applelogo"), action: {}, loading: .constant(false))
            }
            Divider()
            VStack(spacing: 8) {
                Text("Loading")
                    .font(.headline)
                IconButton(title: "Test", icon: Image(systemName: "applelogo"), action: {}, loading: .constant(true))
            }
            Divider()
            VStack(spacing: 8) {
                Text("Disabled")
                    .font(.headline)
                IconButton(title: "Test", icon: Image(systemName: "applelogo"), action: {}, loading: .constant(false))
                    .disabled(true)
            }
        }
        .padding()
    }
}
#endif

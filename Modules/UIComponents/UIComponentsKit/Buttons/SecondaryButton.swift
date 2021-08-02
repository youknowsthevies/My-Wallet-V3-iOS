// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// A `ButtonStyle` for secondary Call-to-Action buttons
public struct SecondaryButtonStyle: ButtonStyle {

    let isEnabled: Bool

    public init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font(weight: .semibold, size: 16))
            .frame(maxWidth: .infinity, minHeight: LayoutConstants.buttonMinHeight)
            .padding(.horizontal)
            .foregroundColor(Color.buttonSecondaryText)
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

/**
 A simple wrapper to `LoadingButton` that applies`SecondaryButtonStyle` to it.

 This is equivalent to writing:
 ```
 LoadingButton(...)
    .buttonStyle(SecondaryButtonStyle())
 ```
 */
public struct SecondaryButton: View {

    let title: String
    let action: () -> Void
    @Binding var loading: Bool
    @Environment(\.isEnabled) var isEnabled

    public init(title: String, action: @escaping () -> Void, loading: Binding<Bool> = .constant(false)) {
        self.title = title
        _loading = loading
        self.action = action
    }

    public var body: some View {
        LoadingButton(title: title, action: action, loading: $loading)
            .buttonStyle(SecondaryButtonStyle(isEnabled: isEnabled))
            .progressViewStyle(CircularProgressViewStyle(tint: .buttonSecondaryText))
    }
}

#if DEBUG
struct SecondaryButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Idle")
                    .font(.headline)
                SecondaryButton(title: "Test", action: {}, loading: .constant(false))
            }
            Divider()
            VStack(spacing: 8) {
                Text("Loading")
                    .font(.headline)
                SecondaryButton(title: "Test", action: {}, loading: .constant(true))
            }
            Divider()
            VStack(spacing: 8) {
                Text("Disabled")
                    .font(.headline)
                SecondaryButton(title: "Test", action: {}, loading: .constant(false))
                    .disabled(true)
            }
        }
        .padding()
    }
}
#endif

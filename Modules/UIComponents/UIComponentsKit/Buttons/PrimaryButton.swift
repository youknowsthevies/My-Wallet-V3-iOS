// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// A `ButtonStyle` for primary Call-to-Action buttons.
public struct PrimaryButtonStyle: ButtonStyle {

    let isEnabled: Bool

    public init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font(weight: .semibold, size: 16))
            .frame(maxWidth: .infinity, minHeight: LayoutConstants.buttonMinHeight)
            .padding(.horizontal)
            .foregroundColor(Color.buttonPrimaryText)
            .background(Color.buttonPrimaryBackground)
            .cornerRadius(LayoutConstants.buttonCornerRadious)
            .opacity(isEnabled ? 1.0 : 0.5)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

/**
 A simple wrapper to `LoadingButton` that applies`PrimaryButtonStyle` to it.

 This is equivalent to writing:
 ```
 LoadingButton(...)
 .buttonStyle(PrimaryButtonStyle())
 ```
 */
public struct PrimaryButton: View {

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
            .buttonStyle(PrimaryButtonStyle(isEnabled: isEnabled))
            .progressViewStyle(CircularProgressViewStyle(tint: .buttonPrimaryText))
    }
}

extension PrimaryButton {

    public init<S>(_ title: S, action: @escaping () -> Void) where S: StringProtocol {
        self.init(title: String(title), action: action)
    }

    //    init(_ titleKey: LocalizedStringKey, action: @escaping () -> Void) // ‼️
}

#if DEBUG
struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Idle")
                    .font(.headline)
                PrimaryButton(title: "Test", action: {}, loading: .constant(false))
            }
            Divider()
            VStack(spacing: 8) {
                Text("Loading")
                    .font(.headline)
                PrimaryButton(title: "Test", action: {}, loading: .constant(true))
            }
            Divider()
            VStack(spacing: 8) {
                Text("Disabled")
                    .font(.headline)
                PrimaryButton(title: "Test", action: {}, loading: .constant(false))
                    .disabled(true)
            }
        }
        .padding()
    }
}
#endif

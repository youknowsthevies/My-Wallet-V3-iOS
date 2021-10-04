// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public struct MinimalDoubleButton: View {

    private let leftButton: (title: String, action: () -> Void)
    private let rightButton: (title: String, action: () -> Void)

    public init(
        leftTitle: String,
        leftAction: @escaping () -> Void,
        rightTitle: String,
        rightAction: @escaping () -> Void
    ) {
        leftButton.title = leftTitle
        leftButton.action = leftAction
        rightButton.title = rightTitle
        rightButton.action = rightAction
    }

    public var body: some View {
        Button(
            action: {},
            label: {
                HStack(spacing: 0) {
                    Button(leftButton.title, action: leftButton.action)
                    Color.dividerLine.frame(width: 1, height: 32)
                    Button(rightButton.title, action: rightButton.action)
                }
                .buttonStyle(MinimalButtonStyle())
            }
        )
        .buttonStyle(MinimalDoubleButtonStyle())
    }
}

private struct MinimalButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .frame(maxWidth: .infinity, minHeight: LayoutConstants.buttonMinHeight)
            .contentShape(Rectangle())
            .background(configuration.isPressed ? Color.buttonMinimalDoublePressedBackground : .clear)
    }
}

private struct MinimalDoubleButtonStyle: ButtonStyle {

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .font(Font(weight: .semibold, size: 16))
            .foregroundColor(.buttonMinimalDoubleText)
            .background(
                RoundedRectangle(cornerRadius: LayoutConstants.buttonCornerRadious)
                    .fill(Color.buttonMinimalDoubleBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: LayoutConstants.buttonCornerRadious)
                    .stroke(configuration.isPressed ? Color.borderFocused : Color.borderPrimary)
            )
            .opacity(isEnabled ? 1.0 : 0.5)
            .clipShape(RoundedRectangle(cornerRadius: LayoutConstants.buttonCornerRadious))
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MinimalDoubleButton(
                leftTitle: "Restore",
                leftAction: {},
                rightTitle: "Log In ->",
                rightAction: {}
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Enabled")

            MinimalDoubleButton(
                leftTitle: "Restore",
                leftAction: {},
                rightTitle: "Log In ->",
                rightAction: {}
            )
            .disabled(true)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Disabled")
        }
        .padding()
    }
}

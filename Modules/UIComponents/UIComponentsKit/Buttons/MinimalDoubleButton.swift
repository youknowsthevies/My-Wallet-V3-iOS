// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public struct MinimalDoubleButton: View {

    private struct ButtonData {
        let image: ImageResource?
        let title: String
        let action: () -> Void
    }

    private let leftButton: ButtonData
    private let rightButton: ButtonData

    public init(
        leftImage: ImageResource? = nil,
        leftTitle: String,
        leftAction: @escaping () -> Void,
        rightImage: ImageResource? = nil,
        rightTitle: String,
        rightAction: @escaping () -> Void
    ) {
        leftButton = ButtonData(
            image: leftImage,
            title: leftTitle,
            action: leftAction
        )
        rightButton = ButtonData(
            image: rightImage,
            title: rightTitle,
            action: rightAction
        )
    }

    public var body: some View {
        Button(
            action: {},
            label: {
                HStack(spacing: 0) {
                    button(data: leftButton)
                    Color.dividerLine.frame(width: 1, height: 32)
                    button(data: rightButton)
                }
                .buttonStyle(MinimalButtonStyle())
            }
        )
        .buttonStyle(MinimalDoubleButtonStyle())
    }

    private func button(
        data: ButtonData
    ) -> some View {
        Button(action: data.action) {
            HStack(spacing: 10) {
                if let image = data.image {
                    ImageResourceView(image)
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                }
                Text(data.title)
            }
        }
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

            MinimalDoubleButton(
                leftImage: .systemName("pencil"),
                leftTitle: "Restore",
                leftAction: {},
                rightImage: .systemName("applelogo"),
                rightTitle: "Log In ->",
                rightAction: {}
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Image + Enabled")

            MinimalDoubleButton(
                leftImage: .systemName("pencil"),
                leftTitle: "Restore",
                leftAction: {},
                rightImage: .systemName("applelogo"),
                rightTitle: "Log In ->",
                rightAction: {}
            )
            .disabled(true)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Image + Disabled")
        }
        .padding()
    }
}

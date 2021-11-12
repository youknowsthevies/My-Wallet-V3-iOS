// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

// MARK: - Public

/// A toggle style switch similar to SwiftUI's `Toggle`
///
/// Note: Unlike SwiftUI's toggle, this animates when the `isOn` binding is changed programatically.
///
/// # Figma
///
/// [PrimarySwitch](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=6%3A1273)
public struct PrimarySwitch: View {
    private let variant: Variant
    private let accessibilityLabel: String
    @Binding private var isOn: Bool

    /// Create a PrimarySwitch
    /// - Parameters:
    ///   - variant: Color variant for the switch. Defaults to `.blue`, see `extension PrimarySwitch.Variant` for predefined variants.
    ///   - accessibilityLabel: Hidden label used for accessibility.
    ///   - isOn: Binding for the switch's on/off state
    public init(
        variant: Variant = .blue,
        accessibilityLabel: String,
        isOn: Binding<Bool>
    ) {
        self.variant = variant
        self.accessibilityLabel = accessibilityLabel
        _isOn = isOn
    }

    public var body: some View {
        Toggle(accessibilityLabel, isOn: $isOn)
            .labelsHidden()
            .toggleStyle(
                PrimarySwitchToggleStyle(onBackgroundColor: variant.onBackgroundColor)
            )
    }

    /// Color variants for PrimarySwitch
    public struct Variant {
        fileprivate let onBackgroundColor: Color
    }
}

extension PrimarySwitch.Variant {
    public static let blue = PrimarySwitch.Variant(
        onBackgroundColor: Color(
            light: .semantic.primary,
            dark: .semantic.primary
        )
    )

    public static let green = PrimarySwitch.Variant(
        onBackgroundColor: Color(
            light: .palette.green400,
            dark: .palette.green400
        )
    )
}

// MARK: - Private

private struct PrimarySwitchToggleStyle: ToggleStyle {
    let onBackgroundColor: Color

    // Layout & Sizing
    private let size = CGSize(width: 51, height: 32)
    private let thumbPadding: CGFloat = 2
    private var edgeOffset: CGFloat {
        (size.width - (size.height - (thumbPadding * 2))) / 2 - thumbPadding
    }

    private let offBackgroundColor = Color(
        light: .semantic.medium,
        dark: .palette.dark600
    )

    private let shadow1Color = Color(
        light: .palette.black.opacity(0.06),
        dark: .palette.black.opacity(0.12)
    )

    private let shadow2Color = Color(
        light: .palette.black.opacity(0.15),
        dark: .palette.black.opacity(0.12)
    )

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Rectangle()
                .fill(
                    configuration.isOn ? onBackgroundColor : offBackgroundColor)

            Circle()
                .fill(
                    Color(
                        light: .palette.white,
                        dark: .palette.dark900
                    )
                )
                .padding(thumbPadding)
                .shadow(color: shadow1Color, radius: 1, x: 0, y: 3)
                .shadow(color: shadow2Color, radius: 8, x: 0, y: 3)
                .offset(x: configuration.isOn ? edgeOffset : -edgeOffset)
        }
        .clipShape(
            RoundedRectangle(cornerRadius: Spacing.roundedBorderRadius(for: size.height))
        )
        .frame(width: size.width, height: size.height)
        .animation(.easeOut(duration: 0.17))
        .onTapGesture {
            configuration.isOn.toggle()
        }
    }
}

// MARK: - Previews

struct PrimarySwitch_Previews: PreviewProvider {
    static var previews: some View {
        PreviewController(variant: .blue, isOn: true)
            .previewLayout(.sizeThatFits)

        PreviewController(variant: .blue, isOn: true)
            .previewLayout(.sizeThatFits)
            .colorScheme(.dark)

        PreviewController(variant: .blue, isOn: false)
            .previewLayout(.sizeThatFits)

        PreviewController(variant: .blue, isOn: false)
            .previewLayout(.sizeThatFits)
            .colorScheme(.dark)

        PreviewController(variant: .green, isOn: true)
            .previewLayout(.sizeThatFits)

        PreviewController(variant: .green, isOn: true)
            .previewLayout(.sizeThatFits)
            .colorScheme(.dark)

        PreviewController(variant: .green, isOn: false)
            .previewLayout(.sizeThatFits)

        PreviewController(variant: .green, isOn: false)
            .previewLayout(.sizeThatFits)
            .colorScheme(.dark)
    }

    struct PreviewController: View {
        let variant: PrimarySwitch.Variant
        @State var isOn: Bool

        var body: some View {
            PrimarySwitch(
                variant: variant,
                accessibilityLabel: "Test",
                isOn: $isOn
            )
        }
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// Radio view.
///
/// # Figma
///
/// [Radio](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=6%3A1262)
public struct Radio: View {

    @Binding private var isOn: Bool
    private let variant: Variant

    /// Create a radio view
    ///
    /// - Parameters:
    ///   - isOn: Binding for the radio's on/off state
    ///   - variant: Optional variant for error case
    public init(isOn: Binding<Bool>, variant: Variant = .default) {
        _isOn = isOn
        self.variant = variant
    }

    public var body: some View {
        Toggle(isOn: $isOn) {
            EmptyView()
        }
        .toggleStyle(RadioToggleStyle(variant: variant))
    }
}

extension Radio {
    /// Color variants for `Radio`
    public struct Variant {
        let backgroundColor: Color
        let borderColor: Color

        /// Default variant
        public static let `default` = Self(
            backgroundColor: .clear,
            borderColor: .semantic.medium
        )

        /// Red colored variant for errors
        public static let error = Self(
            backgroundColor: Color(light: .palette.red000, dark: .palette.red900),
            borderColor: .semantic.error
        )
    }
}

// MARK: - Private

private struct RadioToggleStyle: ToggleStyle {
    let variant: Radio.Variant

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .fill(configuration.isOn ? Color.clear : variant.backgroundColor)

            Circle()
                .strokeBorder(
                    configuration.isOn ? Color.semantic.primary : variant.borderColor,
                    lineWidth: 2.0
                )

            if configuration.isOn {
                Circle()
                    .inset(by: 5)
                    .fill(Color.semantic.primary)
            }
        }
        .frame(width: 24, height: 24)
        .overlay(
            Color.clear
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
                .onTapGesture { configuration.isOn.toggle() }
        )
    }
}

// MARK: - Previews

struct Radio_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            PreviewController(isOn: false, variant: .default)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Unchecked")

            PreviewController(isOn: true, variant: .default)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Checked")

            PreviewController(isOn: false, variant: .error)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Error")
        }
        .padding()
    }

    struct PreviewController: View {
        @State var isOn: Bool
        let variant: Radio.Variant

        var body: some View {
            Radio(isOn: $isOn, variant: variant)
        }
    }
}

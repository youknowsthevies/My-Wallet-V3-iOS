// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// Checkbox view.
/// It can be initialized in checked or unchecked state.
///
/// # Figma
///
/// [Checkbox](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=6%3A1267)
public struct Checkbox: View {

    public enum Variant {
        case standard
        case error
    }

    @Binding private var isOn: Bool
    private let variant: Variant

    /// Create a checkbox view
    /// - Parameters:
    ///   - isOn: Binding for the checkbox's on/off state
    public init(isOn: Binding<Bool>, variant: Variant = .standard) {
        _isOn = isOn
        self.variant = variant
    }

    public var body: some View {
        if variant == .standard {
            Toggle(isOn: $isOn) {
                EmptyView()
            }
            .toggleStyle(CheckboxToggleStandardStyle())
        } else {
            Toggle(isOn: $isOn) {
                EmptyView()
            }
            .toggleStyle(CheckboxToggleErrorStyle())
        }
    }
}

// MARK: - Private

private struct CheckboxToggleStandardStyle: ToggleStyle {

    func makeBody(configuration: Configuration) -> some View {
        Icon.check
            .accentColor(
                configuration.isOn ? .semantic.background : .clear
            )
            .frame(width: 24, height: 24)
            .onTapGesture { configuration.isOn.toggle() }
            .background(
                RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                    .fill(
                        configuration.isOn ? Color.semantic.primary : .semantic.light
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                    .stroke(
                        configuration.isOn ? Color.semantic.primary : .semantic.medium
                    )
            )
    }
}

private struct CheckboxToggleErrorStyle: ToggleStyle {

    func makeBody(configuration: Configuration) -> some View {
        Icon.check
            .accentColor(
                configuration.isOn ? .semantic.background : .clear
            )
            .frame(width: 24, height: 24)
            .onTapGesture { configuration.isOn.toggle() }
            .background(
                RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                    .fill(
                        configuration.isOn ? Color.semantic.primary : .semantic.redBG
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                    .stroke(
                        configuration.isOn ? Color.semantic.primary : .semantic.error
                    )
            )
    }
}

// MARK: - Previews

struct Checkbox_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            PreviewController(isOn: false)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Unchecked")

            PreviewController(isOn: true)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Checked")
        }
        .padding()
    }

    struct PreviewController: View {
        @State var isOn: Bool

        var body: some View {
            Checkbox(isOn: $isOn)
        }
    }
}

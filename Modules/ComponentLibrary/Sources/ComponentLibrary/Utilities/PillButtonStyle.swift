// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

struct PillButtonStyle: ButtonStyle {

    struct ColorSet {
        let foreground: Color
        let background: Color
        let border: Color
    }

    struct ColorStates {
        let enabled: ColorSet
        let pressed: ColorSet
        let disabled: ColorSet
    }

    @Environment(\.isEnabled) private var isEnabled

    let colorStates: ColorStates

    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .typography(.body2)
            .foregroundColor(colorSet(for: configuration).foreground)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(
                RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                    .fill(colorSet(for: configuration).background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                    .stroke(colorSet(for: configuration).border)
            )
    }

    private func colorSet(for configuration: Configuration) -> ColorSet {
        if configuration.isPressed {
            return colorStates.pressed
        } else if isEnabled {
            return colorStates.enabled
        } else {
            return colorStates.disabled
        }
    }
}

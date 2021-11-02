// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

struct PillButtonStyle: ButtonStyle {

    struct ColorSet {
        let foreground: Color
        let background: Color
        let border: Color
    }

    struct ColorCombination {
        let enabled: ColorSet
        let pressed: ColorSet
        let disabled: ColorSet
        let progressViewRail: Color
        let progressViewTrack: Color
    }

    @Environment(\.isEnabled) private var isEnabled

    let isLoading: Bool
    let colorCombination: ColorCombination

    func makeBody(configuration: Configuration) -> some View {
        VStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(
                        ButtonProgressViewStyle(
                            railColor: colorCombination.progressViewRail,
                            trackColor: colorCombination.progressViewTrack
                        )
                    )
                    .frame(width: 24, height: 24)
            } else {
                configuration
                    .label
                    .typography(.body2)
            }
        }
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
            return colorCombination.pressed
        } else if isEnabled {
            return colorCombination.enabled
        } else {
            return colorCombination.disabled
        }
    }
}

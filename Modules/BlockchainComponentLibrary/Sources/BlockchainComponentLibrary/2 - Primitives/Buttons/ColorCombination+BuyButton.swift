// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension PillButtonStyle.ColorCombination {

    static let buyButtonColorCombination = PillButtonStyle.ColorCombination(
        enabled: PillButtonStyle.ColorSet(
            foreground: Color(
                light: .palette.white,
                dark: .palette.white
            ),
            background: .semantic.success,
            border: .semantic.success
        ),
        pressed: PillButtonStyle.ColorSet(
            foreground: .palette.white,
            background: .palette.green700,
            border: .palette.green700
        ),
        disabled: PillButtonStyle.ColorSet(
            foreground: Color(
                light: .palette.white.opacity(0.7),
                dark: .palette.white.opacity(0.4)
            ),
            background: Color(
                light: .palette.green400,
                dark: .palette.green600
            ),
            border: Color(
                light: .palette.green400,
                dark: .palette.green600
            )
        ),
        progressViewRail: .palette.white.opacity(0.8),
        progressViewTrack: .palette.white.opacity(0.25)
    )
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension PillButtonStyle.ColorCombination {

    static let referButtonColorCombination = PillButtonStyle.ColorCombination(
        enabled: PillButtonStyle.ColorSet(
            foreground: Color(
                light: .semantic.primary,
                dark: .semantic.primary
            ),
            background: .palette.white,
            border: .palette.white
        ),
        pressed: PillButtonStyle.ColorSet(
            foreground: .semantic.primary,
            background: .palette.white,
            border: .palette.white
        ),
        disabled: PillButtonStyle.ColorSet(
            foreground: Color(
                light: .semantic.primary.opacity(0.7),
                dark: .semantic.primary.opacity(0.4)
            ),
            background: Color(
                light: .palette.white,
                dark: .palette.white
            ),
            border: Color(
                light: .palette.white,
                dark: .palette.white
            )
        ),
        progressViewRail: .palette.white.opacity(0.8),
        progressViewTrack: .palette.white.opacity(0.25)
    )
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

protocol PillButton {
    var title: String { get }
    var action: () -> Void { get }
    var isLoading: Bool { get }
    var colorSet: PillButtonColorSet { get }
}

struct PillButtonColorSet {
    let enabledState: PillButtonStyle.ColorSet
    let pressedState: PillButtonStyle.ColorSet
    let disabledState: PillButtonStyle.ColorSet
    let progressViewRail: Color
    let progressViewTrack: Color
}

extension PillButton {

    @ViewBuilder func makeBody() -> some View {
        Button(
            action: action,
            label: {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(
                            ButtonProgressViewStyle(
                                railColor: colorSet.progressViewRail,
                                trackColor: colorSet.progressViewTrack
                            )
                        )
                        .frame(width: 24, height: 24)
                } else {
                    Text(title)
                }
            }
        )
        .buttonStyle(
            PillButtonStyle(
                colorStates: PillButtonStyle.ColorStates(
                    enabled: colorSet.enabledState,
                    pressed: colorSet.pressedState,
                    disabled: colorSet.disabledState
                )
            )
        )
    }
}

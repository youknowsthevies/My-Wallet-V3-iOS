// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import ComposableArchitecture
import SwiftUI

struct OnboardingRow: View {

    let item: OnboardingChecklist.Item
    let completed: Bool

    var body: some View {
        PrimaryRow(
            title: item.title,
            caption: item.detail,
            leading: {
                item.icon
                    .frame(width: 28, height: 28)
                    .accentColor(item.accentColor)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                            .fill(item.backgroundColor)
                    )
                    .clipped()
            },
            trailing: {
                if completed {
                    Icon.checkCircle
                        .frame(width: 24, height: 24)
                        .accentColor(.semantic.success)
                } else {
                    Icon.chevronRight
                        .frame(width: 24, height: 24)
                        .accentColor(item.accentColor)
                }
            }
        )
        .padding(2) // to make content fit within rounded corners
        .background(
            RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                .fill(Color.semantic.background)
                .shadow(
                    color: .black.opacity(0.12),
                    radius: 2,
                    x: 1,
                    y: 1
                )
        )
    }
}

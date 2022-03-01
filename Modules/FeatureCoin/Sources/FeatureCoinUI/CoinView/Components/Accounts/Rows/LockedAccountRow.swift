// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

struct LockedAccountRow: View {
    let title: String
    let subtitle: String
    let icon: Icon
    let action: () -> Void

    init(
        title: String,
        subtitle: String,
        icon: Icon,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.action = action
    }

    var body: some View {
        PrimaryRow(
            title: title,
            subtitle: subtitle,
            leading: {
                icon
                    .accentColor(.semantic.muted)
                    .frame(width: 24)
            },
            trailing: {
                Icon.lockClosed
                    .frame(width: 24)
                    .accentColor(.semantic.muted)
            },
            action: {
                action()
            }
        )
    }
}

// swiftlint:disable type_name
struct LockedAccountRow_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            LockedAccountRow(
                title: "Trading Account",
                subtitle: "Buy and Sell Bitcoin",
                icon: .trade,
                action: {}
            )
        }
    }
}

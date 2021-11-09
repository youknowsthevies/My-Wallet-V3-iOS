// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import SwiftUI
import UIComponentsKit

struct InterestAccountListErrorView: View {

    private typealias LocalizationId = LocalizationConstants.Interest.Screen.OverviewError

    private let buttonTapped: () -> Void

    init(action: @escaping () -> Void) {
        buttonTapped = action
    }

    var body: some View {
        NavigationView {
            ActionableView(
                content: {
                    VStack(alignment: .center, spacing: 8.0) {
                        Text(LocalizationId.title)
                            .textStyle(.title)
                        VStack(alignment: .center, spacing: 4.0) {
                            Text(LocalizationId.description)
                                .textStyle(.subheading)
                            Text(LocalizationId.body)
                                .textStyle(.subheading)
                        }
                        Image("sb-intro-bg-theme", bundle: .platformUIKit)
                        Spacer()
                    }
                },
                buttons: [
                    .init(
                        title: LocalizationId.action,
                        action: buttonTapped
                    )
                ]
            )
            .whiteNavigationBarStyle()
            .navigationTitle(LocalizationId.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct InterestAccountListErrorView_Previews: PreviewProvider {
    static var previews: some View {
        InterestAccountListErrorView(action: {})
    }
}

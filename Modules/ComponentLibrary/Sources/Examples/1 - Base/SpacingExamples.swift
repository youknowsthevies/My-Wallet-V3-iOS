// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ComponentLibrary
import SwiftUI

struct SpacingExamplesView: View {

    private let data: NavigationLinkProviderList = [
        "Examples": [
            NavigationLinkProvider(view: GridExamplesView(), title: "Grids"),
            NavigationLinkProvider(view: PaddingExamplesView(), title: "Padding"),
            NavigationLinkProvider(view: BorderRadiiExamplesView(), title: "Border Radii")
        ]
    ]

    var body: some View {
        NavigationLinkProviderView(data: data)
    }
}

struct SpacingExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryNavigationView {
            SpacingExamplesView()
                .primaryNavigation(title: "Spacing")
        }
    }
}

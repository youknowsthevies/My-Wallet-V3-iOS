// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ComponentLibrary
import SwiftUI

struct ButtonsExamplesView: View {

    private let data: NavigationLinkProviderList = [
        "Examples": [
            NavigationLinkProvider(view: PrimaryButtonExamplesView(), title: "PrimaryButton")
        ]
    ]

    var body: some View {
        NavigationLinkProviderView(data: data)
    }
}

struct ButtonsExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonsExamplesView()
    }
}

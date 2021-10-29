// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ComponentLibrary
import SwiftUI

struct ButtonExamplesView: View {

    private let data: NavigationLinkProviderList = [
        "Icons": [
            NavigationLinkProvider(view: IconButtonExamples(), title: "👤 IconButton")
        ],
        "Single Buttons": [],
        "Multi Buttons": []
    ]

    var body: some View {
        NavigationLinkProviderView(data: data)
    }
}

struct ButtonExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ButtonExamplesView()
        }
    }
}

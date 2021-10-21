// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

public struct RootView: View {

    private let data: NavigationLinkProviderList = [
        "1 - Base": [
            NavigationLinkProvider(view: ColorsExamplesView(), title: "🌈 Colors"),
            NavigationLinkProvider(view: TypographyExamplesView(), title: "🔠 Typography"),
            NavigationLinkProvider(view: SpacingExamplesView(), title: "🔳 Spacing Rules"),
            NavigationLinkProvider(view: IconsExamplesView(), title: "🖼 Icons")
        ],
        "2 - Primitives": [
            NavigationLinkProvider(view: SampleView())
        ],
        "3 - Compositions": [
            NavigationLinkProvider(view: Text("Composition Example"))
        ]
    ]

    public init() {}

    public var body: some View {
        NavigationView {
            NavigationLinkProviderView(data: data)
                .navigationTitle("Component Library")
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(
            ColorScheme.allCases,
            id: \.self,
            content: RootView().preferredColorScheme
        )
    }
}

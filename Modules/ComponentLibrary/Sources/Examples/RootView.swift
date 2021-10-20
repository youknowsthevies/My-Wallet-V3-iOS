// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

public struct RootView: View {

    #if os(iOS)
    let listStyle = InsetGroupedListStyle()
    #else
    let listStyle = InsetListStyle()
    #endif

    private let data: NavigationLinkProviderList = [
        "1 - Base": [
            NavigationLinkProvider(view: TypographyExamplesView(), title: "🔠 Typography"),
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
            List {
                NavigationLinkProvider.sections(for: data)
            }
            .listStyle(listStyle)
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

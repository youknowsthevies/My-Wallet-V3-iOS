// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

public struct RootView: View {

    @State var colorScheme: ColorScheme = .light

    private let data: NavigationLinkProviderList = [
        "1 - Base": [
            NavigationLinkProvider(view: ColorsExamplesView(), title: "🌈 Colors"),
            NavigationLinkProvider(view: TypographyExamplesView(), title: "🔠 Typography"),
            NavigationLinkProvider(view: SpacingExamplesView(), title: "🔳 Spacing Rules"),
            NavigationLinkProvider(view: IconsExamplesView(), title: "🖼 Icons")
        ],
        "2 - Primitives": [
            NavigationLinkProvider(view: TabBarExamplesView(), title: "🎼 TabBar"),
            NavigationLinkProvider(view: ButtonExamplesView(), title: "🕹 Buttons"),
            NavigationLinkProvider(view: PrimaryDividerExamples(), title: "🗂 Dividers"),
            NavigationLinkProvider(view: PrimarySwitchExamples(), title: "🔘 PrimarySwitch"),
            NavigationLinkProvider(view: TagExamples(), title: "🏷 Tag")
        ],
        "3 - Compositions": [
            NavigationLinkProvider(view: PrimaryNavigationExamples(), title: "✈️ Navigation"),
            NavigationLinkProvider(view: CalloutCardExamples(), title: "💬 CalloutCard")
        ]
    ]

    public init() {}

    public var body: some View {
        PrimaryNavigationView {
            NavigationLinkProviderView(data: data)
                .primaryNavigation(title: "📚 Component Library") {
                    Button("⚫️ / ⚪️") {
                        colorScheme = colorScheme == .light ? .dark : .light
                    }
                }
        }
        .colorScheme(colorScheme)
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

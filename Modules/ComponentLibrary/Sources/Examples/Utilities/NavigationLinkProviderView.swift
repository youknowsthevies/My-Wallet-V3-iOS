import SwiftUI

public struct NavigationLinkProviderView: View {
    #if os(iOS)
    let listStyle = InsetGroupedListStyle()
    #else
    let listStyle = InsetListStyle()
    #endif

    let data: NavigationLinkProviderList

    public var body: some View {
        List {
            NavigationLinkProvider.sections(for: data)
        }
        .listStyle(listStyle)
    }
}

struct NavigationLinkProviderView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(
            ColorScheme.allCases,
            id: \.self,
            content: NavigationLinkProviderView(
                data: [
                    "Mock": [
                        NavigationLinkProvider(view: Text("Chedder"), title: "🧀 Cheese")
                    ]
                ]
            ).preferredColorScheme
        )
    }
}

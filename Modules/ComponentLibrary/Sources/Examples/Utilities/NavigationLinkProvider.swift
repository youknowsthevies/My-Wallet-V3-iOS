// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public typealias NavigationLinkProviderList = [String: [NavigationLinkProvider]]

public struct NavigationLinkProvider: Hashable {

    public static func == (lhs: NavigationLinkProvider, rhs: NavigationLinkProvider) -> Bool {
        lhs.title == rhs.title
    }

    private let view: AnyView
    private let title: String

    public init<Content: View>(view: Content, title: String? = nil) {
        self.title = title ?? String(describing: type(of: view))
        self.view = AnyView(view.navigationTitle(self.title))
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }

    @ViewBuilder
    public static func sections(for data: NavigationLinkProviderList) -> some View {
        ForEach(Array(data.keys.sorted()), id: \.self) { key in
            if let dict = data[key] {
                Section(header: Text(key)) {
                    links(for: dict)
                }
            }
        }
    }

    @ViewBuilder
    public static func links(for dict: [NavigationLinkProvider]) -> some View {
        ForEach(dict, id: \.self) { linkable in
            NavigationLink(
                destination: linkable.view,
                label: {
                    Text(linkable.title)
                }
            )
        }
    }
}

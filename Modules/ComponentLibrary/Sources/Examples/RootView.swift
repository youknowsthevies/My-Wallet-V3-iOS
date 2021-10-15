// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

public struct RootView: View {

    #if os(iOS)
    let listStyle = InsetGroupedListStyle()
    #else
    let listStyle = InsetListStyle()
    #endif

    public var body: some View {
        NavigationView {
            List {
                Section(header: Text("Base")) {
                    NavigationLink(destination: TypographyExamplesView()) { Text(TypographyExamplesView.title) }
                }
            }
            .listStyle(listStyle)
            .navigationTitle("Component Library")
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

struct SearchBarExamples: View {
    @State var text: String = ""
    @State var isFirstResponder: Bool = false

    var body: some View {
        VStack {
            SearchBar(
                text: $text,
                isFirstResponder: $isFirstResponder,
                cancelButtonText: "Cancel",
                placeholder: "Search Coin"
            ) {
                print("Return tapped")
            }
            .padding(Spacing.padding())

            Spacer()
        }
    }
}

struct SearchBarExamples_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarExamples()
    }
}

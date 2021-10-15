// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ComponentLibrary
import SwiftUI

struct TypographyExamplesView: View {
    static let title = "🔠 Typography"

    var body: some View {
        Typography_Previews.previews
            .navigationTitle(Self.title)
    }
}

struct TypographyExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        TypographyExamplesView()
    }
}

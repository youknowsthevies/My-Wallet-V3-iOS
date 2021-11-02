// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ComponentLibrary
import SwiftUI

struct PaddingExamplesView: View {
    var body: some View {
        ScrollView {
            VStack {
                Spacing_Previews.paddingView(for: Spacing.padding1)
                Spacing_Previews.paddingView(for: Spacing.padding2)
                Spacing_Previews.paddingView(for: Spacing.padding3)
                Spacing_Previews.paddingView(for: Spacing.padding4)
                Spacing_Previews.paddingView(for: Spacing.padding5)
                Spacing_Previews.paddingView(for: Spacing.padding6)
            }
        }
    }
}

struct PaddingExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        PaddingExamplesView()
    }
}

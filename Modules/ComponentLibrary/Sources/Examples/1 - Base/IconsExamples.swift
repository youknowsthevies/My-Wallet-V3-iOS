// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ComponentLibrary
import SwiftUI

struct IconsExamplesView: View {
    var body: some View {
        ScrollView {
            Icon_Previews
                .previews
                .padding(.vertical, 8)
        }
    }
}

struct IconsExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        IconsExamplesView()
    }
}

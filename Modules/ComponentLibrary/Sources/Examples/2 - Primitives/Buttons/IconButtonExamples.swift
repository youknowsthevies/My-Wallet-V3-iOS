// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

struct IconButtonExamples: View {
    @State var tapped: Bool = false

    var body: some View {
        HStack {
            Spacer()

            VStack {
                Text(tapped ? "👍" : "👆")
                    .typography(.display)
                    .padding(.trailing, Spacing.padding1)

                Spacer()
            }
        }
        .primaryNavigation { navigationBarItems }
    }

    @ViewBuilder private var navigationBarItems: some View {
        IconButton(icon: .qrCode) {
            tapped.toggle()
        }
    }
}

struct IconButtonExamples_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryNavigationView {
            IconButtonExamples()
        }
    }
}

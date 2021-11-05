// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

struct CircularIconButtonExamples: View {
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
        CircularIconButton(icon: .chevronLeft) {
            tapped.toggle()
        }
    }
}

struct CircularIconButtonExamples_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryNavigationView {
            CircularIconButtonExamples()
        }
    }
}

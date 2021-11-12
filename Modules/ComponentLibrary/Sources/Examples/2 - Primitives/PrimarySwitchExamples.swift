// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

struct PrimarySwitchExamples: View {
    @State var isOn: Bool = false

    var body: some View {
        VStack {
            PrimarySwitch(accessibilityLabel: "blue", isOn: $isOn)

            PrimarySwitch(variant: .green, accessibilityLabel: "green", isOn: $isOn)
        }
    }
}

struct PrimarySwitchExamples_Previews: PreviewProvider {
    static var previews: some View {
        PrimarySwitchExamples()
    }
}

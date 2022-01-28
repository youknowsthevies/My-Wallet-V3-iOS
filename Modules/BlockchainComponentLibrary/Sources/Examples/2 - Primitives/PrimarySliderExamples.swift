// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

struct PrimarySliderExamples: View {
    @State var value: Float = 5
    let range: ClosedRange<Float> = 0...10

    var body: some View {
        VStack {
            Text("\(value)")

            PrimarySlider(value: $value, in: range, step: 1)

            PrimarySlider(value: $value, in: range)
        }
    }
}

struct PrimarySliderExamples_Previews: PreviewProvider {
    static var previews: some View {
        PrimarySliderExamples()
    }
}

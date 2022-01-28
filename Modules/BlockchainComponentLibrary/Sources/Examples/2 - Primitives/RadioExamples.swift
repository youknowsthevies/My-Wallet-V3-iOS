// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

struct RadioExamples: View {
    @State var choice: Choice = .first

    enum Choice: Hashable {
        case first
        case second
        case third
    }

    var body: some View {
        VStack(spacing: Spacing.baseline) {
            Radio(isOn: binding(for: .first))

            Radio(isOn: binding(for: .second), variant: .error)

            Radio(isOn: binding(for: .third))
        }
        .padding(Spacing.padding())
    }

    func binding(for choice: Choice) -> Binding<Bool> {
        Binding(
            get: { self.choice == choice },
            set: { _ in self.choice = choice }
        )
    }
}

struct RadioExamples_Previews: PreviewProvider {
    static var previews: some View {
        RadioExamples()

        RadioExamples()
            .colorScheme(.dark)
    }
}

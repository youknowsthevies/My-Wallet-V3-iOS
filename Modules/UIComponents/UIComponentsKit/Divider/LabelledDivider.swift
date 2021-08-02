// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public struct LabelledDivider: View {

    let label: String
    let color: Color

    public init(
        label: String,
        color: Color = .dividerLine
    ) {
        self.label = label
        self.color = color
    }

    public var body: some View {
        HStack {
            line
            Text(label)
                .textStyle(.body)
            line
        }
    }

    var line: some View {
        VStack {
            Divider()
                .background(color)
        }
    }
}

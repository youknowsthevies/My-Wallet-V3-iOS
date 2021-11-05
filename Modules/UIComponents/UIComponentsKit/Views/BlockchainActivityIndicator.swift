// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public struct BlockchainActivityIndicator: View {

    private let title: String

    public init(title: String) {
        self.title = title
    }

    public var body: some View {
        VStack(spacing: 16.0) {
            Text(title)
                .textStyle(.title)
        }
    }
}

struct BlockchainActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        BlockchainActivityIndicator(title: "Loading")
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public struct BlockchainActivityIndicator: View {

    public init() {}

    public var body: some View {
        LottieContainerView(name: "loader_v2", loopMode: .loop)
    }
}

struct BlockchainActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        BlockchainActivityIndicator()
    }
}

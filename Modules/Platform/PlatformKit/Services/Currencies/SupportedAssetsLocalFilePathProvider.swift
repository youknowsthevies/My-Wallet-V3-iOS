// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import ToolKit

protocol SupportedAssetsLocalFilePathProviderAPI {
    var remoteERC20Assets: String? { get }
    var localERC20Assets: String? { get }
}

final class SupportedAssetsLocalFilePathProvider: SupportedAssetsLocalFilePathProviderAPI {
    var remoteERC20Assets: String? {
        Bundle(for: Self.self).path(forResource: "remote-currencies-erc20", ofType: "json")
    }

    var localERC20Assets: String? {
        Bundle(for: Self.self).path(forResource: "local-currencies-erc20", ofType: "json")
    }
}

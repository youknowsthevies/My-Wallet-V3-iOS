// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit

final class SupportedAssetsLocalFilePathProviderMock: SupportedAssetsFilePathProviderAPI {
    var remoteEthereumERC20Assets: URL?
    var localEthereumERC20Assets: URL?
    var remotePolygonERC20Assets: URL?
    var localPolygonERC20Assets: URL?
    var remoteCustodialAssets: URL?
    var localCustodialAssets: URL?
}

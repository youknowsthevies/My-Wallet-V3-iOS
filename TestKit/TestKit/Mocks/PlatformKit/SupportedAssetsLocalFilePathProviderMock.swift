// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformKit

final class SupportedAssetsLocalFilePathProviderMock: SupportedAssetsLocalFilePathProviderAPI {
    var remoteERC20Assets: String?
    var localERC20Assets: String?
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import Foundation
import PlatformKit

final class TokenRepository: TokenRepositoryAPI {

    var token: String? {
        nabuTokenStore.sessionToken
    }

    private let nabuTokenStore: NabuTokenStore

    init(nabuTokenStore: NabuTokenStore = resolve()) {
        self.nabuTokenStore = nabuTokenStore
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay

final class BitpayService: BitpayServiceProtocol {

    // MARK: Static Properties

    static let shared = BitpayService()

    // MARK: Properties

    var content: URL?
}

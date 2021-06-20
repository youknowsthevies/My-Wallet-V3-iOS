// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay

final class BitpayService: BitpayServiceProtocol {

    // MARK: Public Properties

    let contentRelay = BehaviorRelay<URL?>(value: nil)

    // MARK: Init

    static let shared = BitpayService()
}

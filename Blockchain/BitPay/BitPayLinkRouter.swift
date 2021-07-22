// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit

class BitPayLinkRouter: DeepLinkRouting {

    // MARK: - Private Properties

    private let service: BitpayServiceProtocol
    @LazyInject var tabControllerProvider: TabControllerManagerProvider

    // MARK: - Init

    init(bitpayService: BitpayServiceProtocol = BitpayService.shared) {
        service = bitpayService
    }

    // MARK: - Static Functions

    static func isBitPayURL(_ url: URL) -> Bool {
        url.absoluteString.contains("https://bitpay.com/")
    }

    // MARK: - DeepLinkRouting

    func routeIfNeeded() -> Bool {
        guard let bitpayURL: URL = service.contentRelay.value else { return false }
        tabControllerProvider.tabControllerManager?.setupBitpayPayment(from: bitpayURL)
        service.contentRelay.accept(nil)
        return true
    }
}

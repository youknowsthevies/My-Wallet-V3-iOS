//
//  BitPayLinkRouter.swift
//  Blockchain
//
//  Created by Alex McGregor on 6/1/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class BitPayLinkRouter: DeepLinkRouting {
    
    // MARK: - Private Properties
    
    private let service: BitpayServiceProtocol
    
    // MARK: - Init
    
    init(bitpayService: BitpayServiceProtocol = BitpayService.shared) {
        self.service = bitpayService
    }
    
    // MARK: - Static Functions
    
    static func isBitPayURL(_ url: URL) -> Bool {
        url.absoluteString.contains("https://bitpay.com/")
    }
    
    // MARK: - DeepLinkRouting

    func routeIfNeeded() -> Bool {
        guard let bitpayURL: URL = service.contentRelay.value else { return false }
        AppCoordinator.shared.tabControllerManager.setupBitpayPayment(from: bitpayURL)
        service.contentRelay.accept(nil)
        return true
    }
}

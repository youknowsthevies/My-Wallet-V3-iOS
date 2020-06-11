//
//  SimpleBuyOrderDetails+Conveniences.swift
//  Blockchain
//
//  Created by Alex McGregor on 6/8/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit

extension BuyActivityItemEvent {
    init(with orderDetails: SimpleBuyOrderDetails) {
        self.init(
            identifier: orderDetails.identifier,
            creationDate: orderDetails.creationDate ?? Date(),
            status: orderDetails.eventStatus,
            fiatValue: orderDetails.fiatValue,
            cryptoValue: orderDetails.cryptoValue,
            fee: orderDetails.fee ?? FiatValue.zero(currency: orderDetails.fiatValue.currency),
            paymentMethod: orderDetails.isBankWire ? .bankTransfer : .card(paymentMethodId: orderDetails.paymentMethodId)
        )
    }
}
extension SimpleBuyOrderDetails {
    fileprivate var eventStatus: BuyActivityItemEvent.EventStatus {
        switch state {
        case .pendingDeposit,
             .pendingConfirmation,
             .depositMatched:
            return .pending
        case .cancelled:
            return .cancelled
        case .expired:
            return .expired
        case .failed:
            return .failed
        case .finished:
            return .finished
        }
    }
}


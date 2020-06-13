//
//  OrderDetails.swift
//  PlatformKit
//
//  Created by Paulo on 31/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit
import Localization
import PlatformKit

public struct OrderDetails {

    typealias LocalizedString = LocalizationConstants.SimpleBuy.OrderState
    // MARK: - Types

    public enum State: String, CaseIterable {
        
        /// Waiting for deposit to be matched
        case pendingDeposit = "PENDING_DEPOSIT"
        
        /// Orders created in this state if pending parameter passed
        case pendingConfirmation = "PENDING_CONFIRMATION"
        
        /// Order canceled no longer eligible to be matched or executed
        case cancelled = "CANCELED"
        
        /// Order matched waiting to execute order
        case depositMatched = "DEPOSIT_MATCHED"
        
        /// Order could not execute
        case failed = "FAILED"
        
        /// Order did not receive deposit or execute in time (default expiration 14 days)
        case expired = "EXPIRED"
        
        /// Order executed and done
        case finished = "FINISHED"

        public var localizedDescription: String {
            switch self {
            case .pendingDeposit:
                return LocalizedString.waitingOnFunds
            case .cancelled:
                return LocalizedString.cancelled
            case .depositMatched:
                return LocalizedString.pending
            case .expired:
                return LocalizedString.expired
            case .failed:
                return LocalizedString.failed
            case .finished:
                return LocalizedString.finished
            case .pendingConfirmation:
                return LocalizedString.pending
            }
        }
    }
    
    // MARK: - Properties

    public var paymentMethod: PaymentMethod.MethodType {
        paymentMethodId == nil ? .bankTransfer : .card([])
    }

    public let creationDate: Date?

    public let fiatValue: FiatValue
    public let cryptoValue: CryptoValue
    
    public var price: FiatValue?
    public var fee: FiatValue?
    
    public let identifier: String
    public let paymentMethodId: String?
    
    public let authorizationData: PartnerAuthorizationData?
    public let state: State
    
    public var isAwaitingAction: Bool {
        isPendingDepositBankWire || isPendingConfirmation || isPending3DSCardOrder
    }
    
    public var isBankWire: Bool {
        paymentMethodId == nil
    }

    public var isCancellable: Bool {
        isPendingDepositBankWire || isPendingConfirmation
    }
    
    public var isPendingConfirmation: Bool {
        state == .pendingConfirmation
    }
    
    public var isPendingDepositBankWire: Bool {
        state == .pendingDeposit && isBankWire
    }
    
    public var isPending3DSCardOrder: Bool {
        guard let state = authorizationData?.state else { return false }
        return paymentMethodId != nil && state.isRequired
    }
    
    public var is3DSConfirmedCardOrder: Bool {
        guard let state = authorizationData?.state else { return false }
        return paymentMethodId != nil && state.isConfirmed
    }
    
    public var isFinal: Bool {
        switch state {
        case .cancelled, .failed, .expired, .finished:
            return true
        case .pendingDeposit, .pendingConfirmation, .depositMatched:
            return false
        }
    }
    
    // MARK: - Setup
    
    init?(recorder: AnalyticsEventRecording, response: OrderPayload.Response) {
        guard let state = State(rawValue: response.state) else {
            return nil
        }
        guard let fiatCurrency = FiatCurrency(code: response.inputCurrency) else {
            return nil
        }
        guard let cryptoCurrency = CryptoCurrency(rawValue: response.outputCurrency) else {
            return nil
        }
        guard let cryptoValue = CryptoValue(minor: response.outputQuantity, cryptoCurreny: cryptoCurrency) else {
            return nil
        }
        identifier = response.id
        fiatValue = FiatValue(minor: response.inputQuantity, currency: fiatCurrency)
        self.cryptoValue = cryptoValue
        self.state = state
        self.paymentMethodId = response.paymentMethodId
        authorizationData = PartnerAuthorizationData(orderPayloadResponse: response)
        
        if let price = response.price {
            self.price = FiatValue(minor: price, currency: fiatCurrency)
        }
        
        if let fee = response.fee {
            self.fee = FiatValue(minor: fee, currency: fiatCurrency)
        }

        creationDate = DateFormatter.utcSessionDateFormat.date(from: response.updatedAt)
        if creationDate == nil {
            recorder.record(event: AnalyticsEvents.DebugEvent.updatedAtParsingError(date: response.updatedAt))
        }
    }
}

extension Array where Element == OrderDetails {
    var pendingDeposit: [OrderDetails] {
        filter { $0.state == .pendingDeposit }
    }
}

private extension AnalyticsEvents {
    enum DebugEvent: AnalyticsEvent {
        case updatedAtParsingError(date: String)

        var name: String {
            switch self {
            case .updatedAtParsingError:
                return "updated_at_parsing_error"
            }
        }
        
        var params: [String : String]? {
            switch self {
            case .updatedAtParsingError(date: let date):
                return ["data" : date]
            }
        }
    }
}

//
//  SimpleBuyOrderDetails.swift
//  PlatformKit
//
//  Created by Paulo on 31/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct SimpleBuyOrderDetails {

    // MARK: - Types

    public enum State: String {
        
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
        
        /// The order is pending execution
        case pendingExecution = "PENDING_EXECUTION"
    }
    
    // MARK: - Properties

    public var paymentMethod: SimpleBuyPaymentMethod.MethodType {
        paymentMethodId == nil ? .bankTransfer : .card
    }
    
    public let fiatValue: FiatValue
    public let cryptoValue: CryptoValue
    public let identifier: String
    public let paymentMethodId: String?
    
    public let authorizationData: PartnerAuthorizationData?
    public let state: State
    
    var isAwaitingAction: Bool {
        switch state {
        case .pendingDeposit where paymentMethodId == nil: // bank
            return true
        case .pendingConfirmation:
            return true
        case .cancelled, .depositMatched, .failed, .expired, .finished, .pendingExecution, .pendingDeposit:
            return false
        }
    }
    
    var isBankWire: Bool {
        paymentMethodId == nil
    }
    
    var isPendingDepositBankWire: Bool {
        state == .pendingDeposit && paymentMethodId == nil
    }
    
    var isFinal: Bool {
        switch state {
        case .cancelled, .failed, .expired, .finished:
            return true
        case .pendingDeposit, .pendingConfirmation, .depositMatched, .pendingExecution:
            return false
        }
    }
    
    // MARK: - Setup
    
    init?(response: SimpleBuyOrderPayload.Response) {
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
    }
}

extension Array where Element == SimpleBuyOrderDetails {
    var pendingDeposit: [SimpleBuyOrderDetails] {
        filter { $0.state == .pendingDeposit }
    }
}

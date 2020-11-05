//
//  CustodyWithdrawalRequestService.swift
//  PlatformKit
//
//  Created by AlexM on 2/12/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Localization
import NetworkKit
import RxSwift

/// Client facing API for submitting a withdrawal.
public protocol CustodyWithdrawalServiceAPI: class {
    
    /// Submit a withdrawal with a `CryptoValue` and corresponding wallet address.
    func makeWithdrawal(amount: CryptoValue, destination: String) -> Single<CustodialWithdrawalResponse>
}

final class CustodyWithdrawalRequestService: CustodyWithdrawalServiceAPI {
    
    // MARK: - Private Properties
    
    private let client: CustodyWithdrawalClientAPI
    
    // MARK: - Init
    
    init(client: CustodyWithdrawalClientAPI = resolve()) {
        self.client = client
    }
    
    // MARK: - SimpleBuyWithdrawalServiceAPI
    
    func makeWithdrawal(amount: CryptoValue, destination: String) -> Single<CustodialWithdrawalResponse> {
        self.client
            .withdraw(cryptoValue: amount, destination: destination)
            .catchError { error in
                guard let communicatorError = error as? NetworkCommunicatorError else {
                    throw error
                }
                throw WithdrawalError(error: communicatorError)
            }
    }
}

public enum WithdrawalError: LocalizedError {
    private typealias LocalizationFailureIDs = LocalizationConstants.SimpleBuy.Withdrawal.SummaryFailure

    case unknown
    case withdrawalLocked

    init(error: NetworkCommunicatorError) {
        switch error {
        case .serverError(let error) where error.nabuError?.code == .some(.withdrawalLocked):
            self = .withdrawalLocked
        default:
            self = .unknown
        }
    }

    public var localizedTitle: String {
        switch self {
        case .unknown:
            return LocalizationFailureIDs.Unknown.title
        case .withdrawalLocked:
            return LocalizationFailureIDs.WithdrawLocked.title
        }
    }

    public var localizedDescription: String {
        switch self {
        case .unknown:
            return LocalizationFailureIDs.Unknown.description
        case .withdrawalLocked:
            return LocalizationFailureIDs.WithdrawLocked.description
        }
    }
}

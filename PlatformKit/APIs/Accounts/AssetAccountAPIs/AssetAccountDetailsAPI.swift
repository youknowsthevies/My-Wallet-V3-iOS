//
//  AssetAccountDetailsAPI.swift
//  PlatformKit
//
//  Created by AlexM on 11/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

/// An API for fetching account `AssetAccountDetails`
public protocol AssetAccountDetailsAPI {
    associatedtype AccountDetails: AssetAccountDetails
    
    /// This will fetch the `AssetAccount` given an `accountID`.
    /// - Parameters:
    /// - accountID: Can be the user's public key or asset specific accountID.
    func accountDetails(for accountID: String) -> Single<AccountDetails>
}

public struct AnyAssetAccountDetailsAPI<AccountDetails: AssetAccountDetails>: AssetAccountDetailsAPI {

    public init<API: AssetAccountDetailsAPI>(service: API) where API.AccountDetails == AccountDetails {
        self._accountDetails = service.accountDetails
    }

    private let _accountDetails: (String) -> Single<AccountDetails>
    public func accountDetails(for accountID: String) -> Single<AccountDetails> {
        _accountDetails(accountID)
    }
}

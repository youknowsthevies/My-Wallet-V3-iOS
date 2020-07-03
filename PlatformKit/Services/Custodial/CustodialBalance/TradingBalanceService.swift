//
//  TradingBalanceService.swift
//  PlatformKit
//
//  Created by Paulo on 10/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol TradingBalanceServiceAPI: AnyObject {
    func balance(for crypto: CryptoCurrency) -> Single<TradingAccountBalanceState>
}

public class TradingBalanceService: TradingBalanceServiceAPI {

    // MARK: - Private Properties
    
    private let client: TradingBalanceClientAPI

    // MARK: - Setup

    public init(client: TradingBalanceClientAPI) {
        self.client = client
    }

    // MARK: - Public Methods

    public func balance(for crypto: CryptoCurrency) -> Single<TradingAccountBalanceState> {
        client
            .balance(for: crypto.code)
            .map { response -> TradingAccountBalanceState in
                guard let response = response else {
                    return .absent
                }
                guard let balance = response[crypto] else {
                    return .absent
                }
                return .present(
                    TradingAccountBalance(
                        currency: crypto,
                        response: balance
                    )
                )
            }
            .catchErrorJustReturn(.absent)
    }
}

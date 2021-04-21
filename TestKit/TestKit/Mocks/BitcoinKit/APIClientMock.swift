//
//  APIClientMock.swift
//  BitcoinKitTests
//
//  Created by Jack on 22/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import BitcoinKit
import BitcoinChainKit
import Foundation
import RxSwift

enum TestAPIClientError: Error {
    case testError
}

class APIClientMock: BitcoinKit.APIClientAPI {
    var underlyingMultiAddress: Single<BitcoinMultiAddressResponse> = .error(TestAPIClientError.testError)
    func multiAddress(for addresses: [APIWalletModel]) -> Single<BitcoinMultiAddressResponse> {
        underlyingMultiAddress
    }

    var underlyingBalances: Single<BitcoinBalanceResponse> = .error(TestAPIClientError.testError)
    func balances(for addresses: [APIWalletModel]) -> Single<BitcoinBalanceResponse> {
        underlyingBalances
    }

    var underlyingUnspentOutputs: Single<UnspentOutputsResponse> = .error(TestAPIClientError.testError)
    func unspentOutputs(for addresses: [APIWalletModel]) -> Single<UnspentOutputsResponse> {
        underlyingUnspentOutputs
    }
}

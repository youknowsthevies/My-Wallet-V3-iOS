//
//  APIClientMock.swift
//  BitcoinKitTests
//
//  Created by Jack on 22/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import BitcoinKit
import Foundation
import RxSwift

class APIClientMock: APIClientAPI {
    var underlyingBitcoinMultiAddress: Single<BitcoinMultiAddressResponse> = .error(APIClientError.unknown)
    func bitcoinMultiAddress(for addresses: [String]) -> Single<BitcoinMultiAddressResponse> {
        underlyingBitcoinMultiAddress
    }

    var underlyingBitcoinBalances: Single<BitcoinBalanceResponse> = .error(APIClientError.unknown)
    func bitcoinBalances(for addresses: [String]) -> Single<BitcoinBalanceResponse> {
        underlyingBitcoinBalances
    }

    var underlyingBitcoinCashMultiAddress: Single<BitcoinCashMultiAddressResponse> = .error(APIClientError.unknown)
    func bitcoinCashMultiAddress(for address: String) -> Single<BitcoinCashMultiAddressResponse> {
        underlyingBitcoinCashMultiAddress
    }

    var underlyingBitcoinCashBalances: Single<BitcoinBalanceResponse> = .error(APIClientError.unknown)
    func bitcoinCashBalances(for addresses: [String]) -> Single<BitcoinBalanceResponse> {
        underlyingBitcoinCashBalances
    }

    var underlyingUnspentOutputs: Single<UnspentOutputsResponse> = .error(APIClientError.unknown)
    func unspentOutputs(addresses: [String]) -> Single<UnspentOutputsResponse> {
        underlyingUnspentOutputs
    }
}

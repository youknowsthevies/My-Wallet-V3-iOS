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
    func bitcoinMultiAddress(for address: String) -> Single<BitcoinMultiAddressResponse> {
        Single.error(APIClientError.unknown)
    }
    
    func bitcoinCashMultiAddress(for address: String) -> Single<BitcoinCashMultiAddressResponse> {
        Single.error(APIClientError.unknown)
    }
    
    var lastUnspentOutputAddresses: [String]?
    var unspentOutputsValue: Single<UnspentOutputsResponse> = Single.error(NSError())
    func unspentOutputs(addresses: [String]) -> Single<UnspentOutputsResponse> {
        lastUnspentOutputAddresses = addresses
        return unspentOutputsValue
    }
}

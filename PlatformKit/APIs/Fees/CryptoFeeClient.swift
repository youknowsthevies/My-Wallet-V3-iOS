//
//  CryptoFeeClient.swift
//  PlatformKit
//
//  Created by Paulo on 04/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import NetworkKit
import RxSwift

final class CryptoFeeClient<FeeType: TransactionFee & Decodable> {

    // MARK: - Types

    private enum Endpoint {
        static var fees: [String] {
            ["mempool", "fees", FeeType.cryptoType.pathComponent]
        }
    }

    // MARK: - Private Properties

    private let requestBuilder: RequestBuilder
    private let communicator: NetworkCommunicatorAPI

    var fees: Single<FeeType> {
        guard let request = requestBuilder.get(path: Endpoint.fees) else {
            return .error(RequestBuilder.Error.buildingRequest)
        }
        return communicator.perform(request: request)
    }

    // MARK: - Init

    init(communicator: NetworkCommunicatorAPI = resolve(),
         requestBuilder: RequestBuilder = resolve()) {
        self.requestBuilder = requestBuilder
        self.communicator = communicator
    }
}

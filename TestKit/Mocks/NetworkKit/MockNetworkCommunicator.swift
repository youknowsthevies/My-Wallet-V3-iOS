//
//  MockCommunicator.swift
//  BlockchainTests
//
//  Created by Jack on 13/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import NetworkKit
import RxSwift

enum CommunicatorMockError: Error {
    case decodingError
}

class MockNetworkCommunicator: NetworkCommunicatorAPI {

    var response: (filename: String, bundle: Bundle)?

    func perform(request: NetworkRequest) -> Completable {
        .empty()
    }

    func perform<ResponseType>(request: NetworkRequest, responseType: ResponseType.Type) -> Completable where ResponseType : Decodable {
        let single: Single<ResponseType> = decode()
        return single.asCompletable()
    }

    func perform<ResponseType, ErrorResponseType>(request: NetworkRequest, responseType: ResponseType.Type, errorResponseType: ErrorResponseType.Type) -> Single<Result<ResponseType, ErrorResponseType>> where ResponseType : Decodable, ErrorResponseType : Decodable, ErrorResponseType : Error {
        .never()
    }

    func perform<ResponseType>(request: NetworkRequest, responseType: ResponseType.Type) -> Single<ResponseType> where ResponseType : Decodable {
        decode()
    }

    func perform<ResponseType>(request: NetworkRequest) -> Single<ResponseType> where ResponseType : Decodable {
        decode()
    }

    private func decode<ResponseType: Decodable>() -> Single<ResponseType> {
        guard
            let response = response,
            let fixture: ResponseType = Fixtures.load(name: response.filename, in: response.bundle) else {
            return .error(CommunicatorMockError.decodingError)
        }
        return .just(fixture)
    }
}

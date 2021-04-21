//
//  NetworkAdapterMock.swift
//  TransactionUIKitTests
//
//  Created by Jack Pooley on 08/04/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Combine
@testable import NetworkKit
import ToolKit

final class NetworkAdapterMock: NetworkAdapterAPI {
    
    var response: (filename: String, bundle: Bundle)?
    
    func performOptional<ResponseType: Decodable>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType?, NetworkCommunicatorError> {
        decode()
    }
    
    func performOptional<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType?, ErrorResponseType> {
        decode()
    }
    
    func perform<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        request: NetworkRequest
    ) -> AnyPublisher<ResponseType, ErrorResponseType> {
        decode()
    }
    
    func perform<ResponseType: Decodable>(
        request: NetworkRequest
    ) -> AnyPublisher<ResponseType, NetworkCommunicatorError> {
        decode()
    }
    
    private func decode<ResponseType: Decodable>(
    ) -> AnyPublisher<ResponseType, NetworkCommunicatorError> {
        guard
            let response = response,
            let fixture: ResponseType = Fixtures.load(name: response.filename, in: response.bundle)
        else {
            return .failure(NetworkCommunicatorError.payloadError(.emptyData))
        }
        return .just(fixture)
    }
    
    private func decode<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
    ) -> AnyPublisher<ResponseType, ErrorResponseType> {
        guard
            let response = response,
            let fixture: ResponseType = Fixtures.load(name: response.filename, in: response.bundle)
        else {
            return .failure(ErrorResponseType.from(NetworkCommunicatorError.payloadError(.emptyData)))
        }
        return .just(fixture)
    }
    
}

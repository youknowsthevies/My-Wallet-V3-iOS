//
//  NetworkAdapter.swift
//  NetworkKit
//
//  Created by Jack Pooley on 25/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Combine
import DIKit
import RxCombine
import RxSwift
import ToolKit

final class NetworkAdapter: NetworkAdapterAPI {
    
    private let communicator: NetworkCommunicatorAPI
    
    init(communicator: NetworkCommunicatorAPI = resolve()) {
        self.communicator = communicator
    }
    
    func performOptional<ResponseType: Decodable>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType?, NetworkCommunicatorError> {
        communicator.dataTaskPublisher(for: request)
            .decodeOptional(responseType: responseType, for: request, using: request.decoder)
    }
    
    func performOptional<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType?, ErrorResponseType> {
        communicator.dataTaskPublisher(for: request)
            .decodeOptional(responseType: responseType, for: request, using: request.decoder)
    }
    
    func perform<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        request: NetworkRequest
    ) -> AnyPublisher<ResponseType, ErrorResponseType> {
        communicator.dataTaskPublisher(for: request)
            .decode(for: request, using: request.decoder)
    }
    
    func perform<ResponseType: Decodable>(
        request: NetworkRequest
    ) -> AnyPublisher<ResponseType, NetworkCommunicatorError> {
        communicator.dataTaskPublisher(for: request)
            .decode(for: request, using: request.decoder)
    }
}

extension AnyPublisher where Output == ServerResponse,
                            Failure == NetworkCommunicatorError {
    
    fileprivate func decodeOptional<ResponseType: Decodable>(
        responseType: ResponseType.Type,
        for request: NetworkRequest,
        using decoder: NetworkResponseDecoderAPI
    ) -> AnyPublisher<ResponseType?, NetworkCommunicatorError> {
        decodeOptionalSuccess(for: request, responseType: responseType, using: decoder)
    }
    
    fileprivate func decodeOptional<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        responseType: ResponseType.Type,
        for request: NetworkRequest,
        using decoder: NetworkResponseDecoderAPI
    ) -> AnyPublisher<ResponseType?, ErrorResponseType> {
        decodeError(for: request, using: decoder)
            .decodeOptionalSuccess(for: request, responseType: responseType, using: decoder)
    }
    
    fileprivate func decode<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        for request: NetworkRequest,
        using decoder: NetworkResponseDecoderAPI
    ) -> AnyPublisher<ResponseType, ErrorResponseType> {
        decodeError(for: request, using: decoder)
            .decodeSuccess(for: request, using: decoder)
    }
    
    fileprivate func decode<ResponseType: Decodable>(
        for request: NetworkRequest,
        using decoder: NetworkResponseDecoderAPI
    ) -> AnyPublisher<ResponseType, NetworkCommunicatorError> {
        decodeSuccess(for: request, using: decoder)
    }
}

extension AnyPublisher where Output == ServerResponse,
                             Failure == NetworkCommunicatorError {
    
    fileprivate func decodeError<ErrorResponseType: ErrorResponseConvertible>(
        for request: NetworkRequest,
        using decoder: NetworkResponseDecoderAPI
    ) -> AnyPublisher<ServerResponse, ErrorResponseType> {
        mapError { communicatorError -> ErrorResponseType in
            switch communicatorError {
            case .rawServerError(let rawServerError):
                return decoder.decode(
                    error: rawServerError, for: request
                )
            default:
                return ErrorResponseType.from(communicatorError)
            }
        }
        .eraseToAnyPublisher()
    }
}

extension AnyPublisher where Output == ServerResponse,
                             Failure: ErrorResponseConvertible {
    
    fileprivate func decodeSuccess<ResponseType: Decodable>(
        for request: NetworkRequest,
        using decoder: NetworkResponseDecoderAPI
    ) -> AnyPublisher<ResponseType, Failure> {
        flatMap { response -> AnyPublisher<ResponseType, Failure> in
            decoder.decode(response: response, for: request).publisher
        }
        .eraseToAnyPublisher()
    }
    
    fileprivate func decodeOptionalSuccess<ResponseType: Decodable>(
        for request: NetworkRequest,
        responseType: ResponseType.Type,
        using decoder: NetworkResponseDecoderAPI
    ) -> AnyPublisher<ResponseType?, Failure> {
        flatMap { response -> AnyPublisher<ResponseType?, Failure> in
            decoder
                .decodeOptional(
                    response: response,
                    responseType: responseType,
                    for: request
                )
                .publisher
        }
        .eraseToAnyPublisher()
    }
}

extension AnyPublisher where Output == ServerResponse,
                             Failure == NetworkCommunicatorError {
    
    fileprivate func decodeSuccess<ResponseType: Decodable>(
        for request: NetworkRequest,
        using decoder: NetworkResponseDecoderAPI
    ) -> AnyPublisher<ResponseType, NetworkCommunicatorError> {
        flatMap { response -> AnyPublisher<ResponseType, NetworkCommunicatorError> in
            decoder.decode(response: response, for: request).publisher
        }
        .eraseToAnyPublisher()
    }
    
    fileprivate func decodeOptionalSuccess<ResponseType: Decodable>(
        for request: NetworkRequest,
        responseType: ResponseType.Type,
        using decoder: NetworkResponseDecoderAPI
    ) -> AnyPublisher<ResponseType?, NetworkCommunicatorError> {
        flatMap { response -> AnyPublisher<ResponseType?, NetworkCommunicatorError> in
            decoder
                .decodeOptional(
                    response: response,
                    responseType: responseType,
                    for: request
                )
                .publisher
        }
        .eraseToAnyPublisher()
    }
}

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
    
    private let communicator: NetworkCommunicatorNewAPI
    
    init(communicator: NetworkCommunicatorNewAPI = resolve()) {
        self.communicator = communicator
    }
    
    func performOptional<ResponseType: Decodable>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType?, NetworkCommunicatorErrorNew> {
        communicator.dataTaskPublisher(for: request)
            .decodeOptional(responseType: responseType, using: request.decoder)
    }
    
    func performOptional<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType?, ErrorResponseType> {
        communicator.dataTaskPublisher(for: request)
            .decodeOptional(responseType: responseType, using: request.decoder)
    }
    
    func perform<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        request: NetworkRequest
    ) -> AnyPublisher<ResponseType, ErrorResponseType> {
        communicator.dataTaskPublisher(for: request)
            .decode(using: request.decoder)
    }
    
    func perform<ResponseType: Decodable>(
        request: NetworkRequest
    ) -> AnyPublisher<ResponseType, NetworkCommunicatorErrorNew> {
        communicator.dataTaskPublisher(for: request)
            .decode(using: request.decoder)
    }
}

extension AnyPublisher where Output == ServerResponseNew,
                            Failure == NetworkCommunicatorErrorNew {
    
    fileprivate func decodeOptional<ResponseType: Decodable>(
        responseType: ResponseType.Type,
        using decoder: NetworkResponseDecoderNewAPI
    ) -> AnyPublisher<ResponseType?, NetworkCommunicatorErrorNew> {
        decodeOptionalSuccess(responseType: responseType, using: decoder)
    }
    
    fileprivate func decodeOptional<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        responseType: ResponseType.Type,
        using decoder: NetworkResponseDecoderNewAPI
    ) -> AnyPublisher<ResponseType?, ErrorResponseType> {
        decodeError(using: decoder)
            .decodeOptionalSuccess(responseType: responseType, using: decoder)
    }
    
    fileprivate func decode<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        using decoder: NetworkResponseDecoderNewAPI
    ) -> AnyPublisher<ResponseType, ErrorResponseType> {
        decodeError(using: decoder)
            .decodeSuccess(using: decoder)
    }
    
    fileprivate func decode<ResponseType: Decodable>(
        using decoder: NetworkResponseDecoderNewAPI
    ) -> AnyPublisher<ResponseType, NetworkCommunicatorErrorNew> {
        decodeSuccess(using: decoder)
    }
}

extension AnyPublisher where Output == ServerResponseNew,
                             Failure == NetworkCommunicatorErrorNew {
    
    fileprivate func decodeError<ErrorResponseType: ErrorResponseConvertible>(
        using decoder: NetworkResponseDecoderNewAPI
    ) -> AnyPublisher<ServerResponseNew, ErrorResponseType> {
        mapError { communicatorError -> ErrorResponseType in
            switch communicatorError {
            case .rawServerError(let rawServerError):
                return decoder.decode(
                    error: rawServerError
                )
            default:
                return ErrorResponseType.from(communicatorError)
            }
        }
        .eraseToAnyPublisher()
    }
}

extension AnyPublisher where Output == ServerResponseNew,
                             Failure: ErrorResponseConvertible {
    
    fileprivate func decodeSuccess<ResponseType: Decodable>(
        using decoder: NetworkResponseDecoderNewAPI
    ) -> AnyPublisher<ResponseType, Failure> {
        flatMap { response -> AnyPublisher<ResponseType, Failure> in
            decoder.decode(response: response).publisher
        }
        .eraseToAnyPublisher()
    }
    
    fileprivate func decodeOptionalSuccess<ResponseType: Decodable>(
        responseType: ResponseType.Type,
        using decoder: NetworkResponseDecoderNewAPI
    ) -> AnyPublisher<ResponseType?, Failure> {
        flatMap { response -> AnyPublisher<ResponseType?, Failure> in
            decoder.decodeOptional(response: response, responseType: responseType).publisher
        }
        .eraseToAnyPublisher()
    }
}

extension AnyPublisher where Output == ServerResponseNew,
                             Failure == NetworkCommunicatorErrorNew {
    
    fileprivate func decodeSuccess<ResponseType: Decodable>(
        using decoder: NetworkResponseDecoderNewAPI
    ) -> AnyPublisher<ResponseType, NetworkCommunicatorErrorNew> {
        flatMap { response -> AnyPublisher<ResponseType, NetworkCommunicatorErrorNew> in
            decoder.decode(response: response).publisher
        }
        .eraseToAnyPublisher()
    }
    
    fileprivate func decodeOptionalSuccess<ResponseType: Decodable>(
        responseType: ResponseType.Type,
        using decoder: NetworkResponseDecoderNewAPI
    ) -> AnyPublisher<ResponseType?, NetworkCommunicatorErrorNew> {
        flatMap { response -> AnyPublisher<ResponseType?, NetworkCommunicatorErrorNew> in
            decoder.decodeOptional(response: response, responseType: responseType).publisher
        }
        .eraseToAnyPublisher()
    }
}

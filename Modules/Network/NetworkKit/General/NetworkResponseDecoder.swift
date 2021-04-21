//
//  ResponseDecoder.swift
//  PlatformKit
//
//  Created by Jack on 21/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import ToolKit

public protocol NetworkResponseDecoderAPI {

    func decodeOptional<ResponseType: Decodable>(
        response: ServerResponse,
        responseType: ResponseType.Type,
        for request: NetworkRequest
    ) -> Result<ResponseType?, NetworkCommunicatorError>
    
    func decodeOptional<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        response: ServerResponse,
        responseType: ResponseType.Type,
        for request: NetworkRequest
    ) -> Result<ResponseType?, ErrorResponseType>
    
    func decode<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        response: ServerResponse,
        for request: NetworkRequest
    ) -> Result<ResponseType, ErrorResponseType>
    
    func decode<ResponseType: Decodable>(
        response: ServerResponse,
        for request: NetworkRequest
    ) -> Result<ResponseType, NetworkCommunicatorError>
    
    func decode<ErrorResponseType: ErrorResponseConvertible>(
        error: ServerErrorResponse,
        for request: NetworkRequest
    ) -> ErrorResponseType
    
    func decodeFailureToString(errorResponse: ServerErrorResponse) -> String?
}

final class NetworkResponseDecoder: NetworkResponseDecoderAPI {
    
    // MARK: - Properties

    private static let defaultJSONDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()

    private let jsonDecoder: JSONDecoder
    
    // MARK: - Setup

    init(jsonDecoder: JSONDecoder = NetworkResponseDecoder.defaultJSONDecoder) {
        self.jsonDecoder = jsonDecoder
    }
    
    // MARK: - NetworkResponseDecoderAPI
    
    public func decodeOptional<ResponseType: Decodable>(
        response: ServerResponse,
        responseType: ResponseType.Type,
        for request: NetworkRequest
    ) -> Result<ResponseType?, NetworkCommunicatorError> {
        decode(
            response: response,
            for: request,
            emptyPayloadHandler: { serverResponse in
                guard serverResponse.response.statusCode == 204 else {
                    return .failure(.payloadError(.emptyData))
                }
                return .success(nil)
            }
        )
    }
    
    public func decodeOptional<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        response: ServerResponse,
        responseType: ResponseType.Type,
        for request: NetworkRequest
    ) -> Result<ResponseType?, ErrorResponseType> {
        decode(
            response: response,
            for: request,
            emptyPayloadHandler: { serverResponse in
                guard serverResponse.response.statusCode == 204 else {
                    return .failure(.payloadError(.emptyData))
                }
                return .success(nil)
            }
        )
        .mapError(ErrorResponseType.from)
    }
    
    public func decode<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        response: ServerResponse,
        for request: NetworkRequest
    ) -> Result<ResponseType, ErrorResponseType> {
        decode(response: response, for: request)
            .mapError(ErrorResponseType.from)
    }
    
    public func decode<ResponseType: Decodable>(
        response: ServerResponse,
        for request: NetworkRequest
    ) -> Result<ResponseType, NetworkCommunicatorError> {
        decode(
            response: response,
            for: request,
            emptyPayloadHandler: { _ in
                .failure(.payloadError(.emptyData))
            }
        )
    }
    
    public func decode<ErrorResponseType: ErrorResponseConvertible>(
        error: ServerErrorResponse,
        for request: NetworkRequest
    ) -> ErrorResponseType {
        guard let payload = error.payload else {
            return ErrorResponseType.from(.payloadError(.emptyData))
        }
        let decodedErrorResponse: ErrorResponseType
        do {
            decodedErrorResponse = try jsonDecoder.decode(ErrorResponseType.self, from: payload)
        } catch let decodingError {
            Logger.shared.error(error.response.url!.absoluteString)
            let rawPayload = String(data: payload, encoding: .utf8) ?? ""
            let errorMessage = debugErrorMessage(
                for: decodingError,
                response: error.response,
                responseType: ErrorResponseType.self,
                request: request,
                rawPayload: rawPayload
            )
            Logger.shared.debug(errorMessage)
            // TODO: Fix decoding errors then uncomment this: https://blockchain.atlassian.net/browse/IOS-4501
            // #if INTERNAL_BUILD
            // fatalError(errorMessage)
            // #endif
            return ErrorResponseType.from(.payloadError(.badData(rawPayload: rawPayload)))
        }
        return decodedErrorResponse
    }
    
    public func decodeFailureToString(errorResponse: ServerErrorResponse) -> String? {
        guard let payload = errorResponse.payload else {
            return nil
        }
        return String(data: payload, encoding: .utf8)
    }
    
    // MARK: - Private methods
    
    private func decode<ResponseType: Decodable>(
        response: ServerResponse,
        for request: NetworkRequest,
        emptyPayloadHandler: (ServerResponse) -> Result<ResponseType, NetworkCommunicatorError>
    ) -> Result<ResponseType, NetworkCommunicatorError> {
        guard ResponseType.self != EmptyNetworkResponse.self else {
            let emptyResponse: ResponseType = EmptyNetworkResponse() as! ResponseType
            return .success(emptyResponse)
        }
        guard let payload = response.payload else {
            return emptyPayloadHandler(response)
        }
        guard ResponseType.self != RawServerResponse.self else {
            let message = String(data: payload, encoding: .utf8) ?? ""
            let rawResponse = RawServerResponse(data: message) as! ResponseType
            return .success(rawResponse)
        }
        return Result { try self.jsonDecoder.decode(ResponseType.self, from: payload) }
            .flatMapError { decodingError -> Result<ResponseType, NetworkCommunicatorError> in
                Logger.shared.error(response.response.url!.absoluteString)
                let rawPayload = String(data: payload, encoding: .utf8) ?? ""
                let errorMessage = debugErrorMessage(
                    for: decodingError,
                    response: response.response,
                    responseType: ResponseType.self,
                    request: request,
                    rawPayload: rawPayload
                )
                Logger.shared.debug(errorMessage)
                // TODO: Fix decoding errors then uncomment this: https://blockchain.atlassian.net/browse/IOS-4501
                // #if INTERNAL_BUILD
                // fatalError(errorMessage)
                // #endif
                return .failure(.payloadError(.badData(rawPayload: rawPayload)))
            }
    }
    
    private func debugErrorMessage<ResponseType: Decodable>(
        for decodingError: Error,
        response: HTTPURLResponse,
        responseType: ResponseType.Type,
        request: NetworkRequest,
        rawPayload: String
    ) -> String {
        return """
        \n----------------------
        Payload decoding error.
          Error: '\(String(describing: ResponseType.self))': \(decodingError).
            URL: \(response.url!.absoluteString),
        Request: \(request),
        Payload: \(rawPayload)
        ======================\n
        """
    }
}


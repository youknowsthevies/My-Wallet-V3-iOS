//
//  NetworkResponseDecoder.swift
//  NetworkKit
//
//  Created by Jack Pooley on 25/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit

public protocol NetworkResponseDecoderNewAPI {

    func decodeOptional<ResponseType: Decodable>(
        response: ServerResponseNew,
        responseType: ResponseType.Type
    ) -> Result<ResponseType?, NetworkCommunicatorErrorNew>
    
    func decodeOptional<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        response: ServerResponseNew,
        responseType: ResponseType.Type
    ) -> Result<ResponseType?, ErrorResponseType>
    
    func decode<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        response: ServerResponseNew
    ) -> Result<ResponseType, ErrorResponseType>
    
    func decode<ResponseType: Decodable>(
        response: ServerResponseNew
    ) -> Result<ResponseType, NetworkCommunicatorErrorNew>
    
    func decode<ErrorResponseType: ErrorResponseConvertible>(
        error: ServerErrorResponseNew
    ) -> ErrorResponseType
    
    func decodeFailureToString(errorResponse: ServerErrorResponseNew) -> String?
}

// TODO: move this to it's own class/struct once the legacy network stack is completely replaced
extension NetworkResponseDecoder {
    
    public func decodeOptional<ResponseType: Decodable>(
        response: ServerResponseNew,
        responseType: ResponseType.Type
    ) -> Result<ResponseType?, NetworkCommunicatorErrorNew> {
        decode(
            response: response,
            emptyPayloadHandler: { serverResponse in
                guard serverResponse.response.statusCode == 204 else {
                    return .failure(.payloadError(.emptyData))
                }
                return .success(nil)
            }
        )
    }
    
    public func decodeOptional<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        response: ServerResponseNew,
        responseType: ResponseType.Type
    ) -> Result<ResponseType?, ErrorResponseType> {
        decode(
            response: response,
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
        response: ServerResponseNew
    ) -> Result<ResponseType, ErrorResponseType> {
        decode(response: response)
            .mapError(ErrorResponseType.from)
    }
    
    public func decode<ResponseType: Decodable>(
        response: ServerResponseNew
    ) -> Result<ResponseType, NetworkCommunicatorErrorNew> {
        decode(
            response: response,
            emptyPayloadHandler: { _ in
                .failure(.payloadError(.emptyData))
            }
        )
    }
    
    public func decode<ErrorResponseType: ErrorResponseConvertible>(
        error: ServerErrorResponseNew
    ) -> ErrorResponseType {
        guard let payload = error.payload else {
            return ErrorResponseType.from(.payloadError(.emptyData))
        }
        let decodedErrorResponse: ErrorResponseType
        do {
            decodedErrorResponse = try jsonDecoder.decode(ErrorResponseType.self, from: payload)
        } catch let decodingError {
            Logger.shared.error(error.response.url!.absoluteString)
            Logger.shared.debug("Error payload decoding 'ErrorResponseType'. Error: \(decodingError)")
            let rawPayload = String(data: payload, encoding: .utf8) ?? ""
            Logger.shared.debug("Raw Payload: \(rawPayload)")
            return ErrorResponseType.from(.payloadError(.badData(rawPayload: rawPayload)))
        }
        return decodedErrorResponse
    }
    
    public func decodeFailureToString(errorResponse: ServerErrorResponseNew) -> String? {
        guard let payload = errorResponse.payload else {
            return nil
        }
        return String(data: payload, encoding: .utf8)
    }
    
    // MARK: - Private methods
    
    private func decode<ResponseType: Decodable>(
        response: ServerResponseNew,
        emptyPayloadHandler: (ServerResponseNew) -> Result<ResponseType, NetworkCommunicatorErrorNew>
    ) -> Result<ResponseType, NetworkCommunicatorErrorNew> {
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
            .flatMapError { decodingError -> Result<ResponseType, NetworkCommunicatorErrorNew> in
                Logger.shared.error(response.response.url!.absoluteString)
                Logger.shared.debug("Payload decoding error '\(String(describing: ResponseType.self))': \(decodingError)")
                let message = String(data: payload, encoding: .utf8) ?? ""
                Logger.shared.debug("Message: \(message)")
                return .failure(.payloadError(.badData(rawPayload: message)))
            }
    }
}

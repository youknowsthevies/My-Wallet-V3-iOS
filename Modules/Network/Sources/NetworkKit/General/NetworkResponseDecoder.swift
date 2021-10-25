// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import NetworkError
import ToolKit

public protocol NetworkResponseDecoderAPI {

    func decodeOptional<ResponseType: Decodable>(
        response: ServerResponse,
        responseType: ResponseType.Type,
        for request: NetworkRequest
    ) -> Result<ResponseType?, NetworkError>

    func decodeOptional<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        response: ServerResponse,
        responseType: ResponseType.Type,
        for request: NetworkRequest
    ) -> Result<ResponseType?, ErrorResponseType>

    func decode<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        response: ServerResponse,
        for request: NetworkRequest
    ) -> Result<ResponseType, ErrorResponseType>

    func decode<ResponseType: Decodable>(
        response: ServerResponse,
        for request: NetworkRequest
    ) -> Result<ResponseType, NetworkError>

    func decode<ErrorResponseType: FromNetworkErrorConvertible>(
        error: ServerErrorResponse,
        for request: NetworkRequest
    ) -> ErrorResponseType

    func decodeFailureToString(errorResponse: ServerErrorResponse) -> String?
}

public final class NetworkResponseDecoder: NetworkResponseDecoderAPI {

    // MARK: - Properties

    public static let defaultJSONDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()

    private let jsonDecoder: JSONDecoder

    // MARK: - Setup

    public init(jsonDecoder: JSONDecoder = NetworkResponseDecoder.defaultJSONDecoder) {
        self.jsonDecoder = jsonDecoder
    }

    // MARK: - NetworkResponseDecoderAPI

    public func decodeOptional<ResponseType: Decodable>(
        response: ServerResponse,
        responseType: ResponseType.Type,
        for request: NetworkRequest
    ) -> Result<ResponseType?, NetworkError> {
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

    public func decodeOptional<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
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

    public func decode<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        response: ServerResponse,
        for request: NetworkRequest
    ) -> Result<ResponseType, ErrorResponseType> {
        decode(response: response, for: request)
            .mapError(ErrorResponseType.from)
    }

    public func decode<ResponseType: Decodable>(
        response: ServerResponse,
        for request: NetworkRequest
    ) -> Result<ResponseType, NetworkError> {
        decode(
            response: response,
            for: request,
            emptyPayloadHandler: { _ in
                .failure(.payloadError(.emptyData))
            }
        )
    }

    public func decode<ErrorResponseType: FromNetworkErrorConvertible>(
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
            let rawPayload = String(data: payload, encoding: .utf8) ?? ""
            let errorMessage = debugErrorMessage(
                for: decodingError,
                response: error.response,
                responseType: ErrorResponseType.self,
                request: request,
                rawPayload: rawPayload
            )
            Logger.shared.error(errorMessage)
            // TODO: Fix decoding errors then uncomment this: IOS-4501
            // if BuildFlag.isInternal {
            //     fatalError(errorMessage)
            // }
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
        emptyPayloadHandler: (ServerResponse) -> Result<ResponseType, NetworkError>
    ) -> Result<ResponseType, NetworkError> {
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
        guard ResponseType.self != String.self else {
            let message = String(data: payload, encoding: .utf8) ?? ""
            return .success(message as! ResponseType)
        }
        return Result { try self.jsonDecoder.decode(ResponseType.self, from: payload) }
            .flatMapError { decodingError -> Result<ResponseType, NetworkError> in
                let rawPayload = String(data: payload, encoding: .utf8) ?? ""
                let errorMessage = debugErrorMessage(
                    for: decodingError,
                    response: response.response,
                    responseType: ResponseType.self,
                    request: request,
                    rawPayload: rawPayload
                )
                Logger.shared.error(errorMessage)
                // TODO: Fix decoding errors then uncomment this: IOS-4501
                // if BuildFlag.isInternal {
                //     fatalError(errorMessage)
                // }
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
        """
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

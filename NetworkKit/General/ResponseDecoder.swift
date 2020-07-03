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

public struct ServerResponse {
    let response: HTTPURLResponse
    let payload: Data?
}

public struct ServerErrorResponse: Error {
    public let response: HTTPURLResponse
    public let payload: Data?
}

extension PrimitiveSequence where Trait == SingleTrait, Element == Result<ServerResponse, ServerErrorResponse> {
    func decode<ResponseType: Decodable, ErrorResponseType: Error & Decodable>(
        with decoder: NetworkResponseDecoderAPI
    ) -> Single<Result<ResponseType, ErrorResponseType>> {
        flatMap { result -> Single<Result<ResponseType, ErrorResponseType>> in
            decoder.decode(result: result)
        }
    }

    func decode<ResponseType: Decodable>(with decoder: NetworkResponseDecoderAPI) -> Single<ResponseType> {
        flatMap { result -> Single<ResponseType> in
            decoder.decode(result: result)
        }
    }

    func decodeOptional<ResponseType: Decodable>(with decoder: NetworkResponseDecoderAPI) -> Single<ResponseType?> {
        flatMap { result -> Single<ResponseType?> in
            decoder.decodeOptional(result: result)
        }
    }
}

extension PrimitiveSequence where Trait == SingleTrait, Element == ServerResponse {
    func decode<ResponseType: Decodable>(with decoder: NetworkResponseDecoderAPI) -> Single<ResponseType> {
        flatMap { response -> Single<ResponseType> in
            decoder.decode(response: response)
        }
    }
}

public protocol NetworkResponseDecoderAPI {
    func decode<ResponseType: Decodable>(response: ServerResponse) -> Single<ResponseType>
    func decode<ResponseType: Decodable>(result: Result<ServerResponse, ServerErrorResponse>) -> Single<ResponseType>
    func decodeOptional<ResponseType: Decodable>(result: Result<ServerResponse, ServerErrorResponse>) -> Single<ResponseType?>
    func decode<ResponseType: Decodable, ErrorResponseType: Error & Decodable>(
        result: Result<ServerResponse, ServerErrorResponse>
    ) -> Single<Result<ResponseType, ErrorResponseType>>
    func decodeFailureToString(errorResponse: ServerErrorResponse) -> String?
}

public class NetworkResponseDecoder: NetworkResponseDecoderAPI {

    // FIXME: Fetch decoder from Container (in the future)
    public static let `default` = NetworkResponseDecoder()

    public static let defaultJSONDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()

    private let jsonDecoder: JSONDecoder

    public init(jsonDecoder: JSONDecoder = NetworkResponseDecoder.defaultJSONDecoder) {
        self.jsonDecoder = jsonDecoder
    }

    // MARK: - NetworkResponseDecoderAPI

    public func decode<ResponseType: Decodable>(response: ServerResponse) -> Single<ResponseType> {
        return decode(networkResponse: response).single
    }

    public func decode<ResponseType: Decodable>(result: Result<ServerResponse, ServerErrorResponse>) -> Single<ResponseType> {
        switch result {
        case .success(let networkResponse):
            return decode(networkResponse: networkResponse).single
        case .failure(let networkErrorResponse):
            return decodeWithDefaultDecoding(networkErrorResponse: networkErrorResponse).single
        }
    }

    public func decodeOptional<ResponseType: Decodable>(result: Result<ServerResponse, ServerErrorResponse>) -> Single<ResponseType?> {
        switch result {
        case .success(let networkResponse):
            return decodeOptional(networkResponse: networkResponse).single
        case .failure(let networkErrorResponse):
            return decodeWithDefaultDecoding(networkErrorResponse: networkErrorResponse).single
        }
    }

    public func decode<ResponseType: Decodable, ErrorResponseType: Error & Decodable>(result: Result<ServerResponse, ServerErrorResponse>) -> Single<Result<ResponseType, ErrorResponseType>> {
        switch result {
        case .success(let networkResponse):
            return Result<Result<ResponseType, Never>, Error> {
                    try decodeSuccess(response: networkResponse, type: ResponseType.self)
                }
                .map { result -> Result<ResponseType, ErrorResponseType> in
                    result.mapError()
                }
                .single
        case .failure(let networkErrorResponse):
            return Result<Result<Never, ErrorResponseType>, Error> {
                    try decodeFailure(errorResponse: networkErrorResponse)
                }
                .map { result -> Result<ResponseType, ErrorResponseType> in
                    result.map()
                }
                .single
        }
    }

    public func decodeFailureToString(errorResponse: ServerErrorResponse) -> String? {
        guard let payload = errorResponse.payload else {
            return nil
        }
        return String(data: payload, encoding: .utf8)
    }

    // MARK: - Private methods

    private func decode<ResponseType: Decodable>(networkResponse: ServerResponse) -> Result<ResponseType, Error> {
        return Result<Result<ResponseType, Never>, Error> {
               try decodeSuccess(response: networkResponse, type: ResponseType.self)
            }
            .flatMap { result -> Result<ResponseType, Error> in
                result.mapError(to: Error.self)
            }
    }

    private func decodeOptional<ResponseType: Decodable>(networkResponse: ServerResponse) -> Result<ResponseType?, Error> {
        return Result<Result<ResponseType?, Never>, Error> {
               try decodeSuccessOptional(response: networkResponse, type: ResponseType.self)
            }
            .flatMap { result -> Result<ResponseType?, Error> in
                result.mapError(to: Error.self)
            }
    }

    private func decode<ResponseType: Decodable, ErrorResponseType: Error & Decodable>(
        networkErrorResponse: ServerErrorResponse
    ) throws -> Result<ResponseType, ErrorResponseType> {
        return try decodeFailure(errorResponse: networkErrorResponse).map()
    }

    private func decodeWithDefaultDecoding<ResponseType: Decodable>(networkErrorResponse: ServerErrorResponse) -> Result<ResponseType, Error> {
        let errorResult: Result<Never, NabuNetworkError>
        do {
            errorResult = try decodeFailure(errorResponse: networkErrorResponse)
        } catch {
            return .failure(error)
        }

        guard case .failure(let errorPayload) = errorResult else {
            return .failure(NetworkCommunicatorError.payloadError(.emptyData))
        }

        guard let payload = networkErrorResponse.payload else {
            return .failure(NetworkCommunicatorError.payloadError(.emptyData))
        }

        let message = String(data: payload, encoding: .utf8) ?? ""
        let errorStatusCode = HTTPRequestServerError.badStatusCode(
            code: networkErrorResponse.response.statusCode,
            error: errorPayload,
            message: message
        )
        return .failure(NetworkCommunicatorError.serverError(errorStatusCode))
    }

    private func decodeFailure<ErrorResponseType: Error & Decodable>(errorResponse: ServerErrorResponse) throws -> Result<Never, ErrorResponseType> {
        guard let payload = errorResponse.payload else {
            throw NetworkCommunicatorError.payloadError(.emptyData)
        }
        let decodedErrorResponse: ErrorResponseType
        do {
            decodedErrorResponse = try self.jsonDecoder.decode(ErrorResponseType.self, from: payload)
        } catch let decodingError {
            Logger.shared.error(errorResponse.response.url!.absoluteString)
            Logger.shared.debug("Error payload decoding 'ErrorResponseType'. Error: \(decodingError)")
            let message = String(data: payload, encoding: .utf8) ?? ""
            Logger.shared.debug("Message: \(message)")
            throw NetworkCommunicatorError.payloadError(.badData(rawPayload: message))
        }
        return .failure(decodedErrorResponse)
    }

    private func decodeSuccess<ResponseType: Decodable>(response: ServerResponse, type: ResponseType.Type) throws -> Result<ResponseType, Never> {
        try decodeSuccess(response: response)
    }

    private func decodeSuccessOptional<ResponseType: Decodable>(
        response: ServerResponse, type: ResponseType.Type
    ) throws -> Result<ResponseType?, Never> {
        try decodeSuccessOptional(response: response)
    }

    private func decodeSuccessOptional<ResponseType: Decodable>(response: ServerResponse) throws -> Result<ResponseType?, Never> {
        guard ResponseType.self != EmptyNetworkResponse.self else {
            let emptyResponse: ResponseType = EmptyNetworkResponse() as! ResponseType
            return .success(emptyResponse)
        }
        guard response.payload != nil else {
            guard response.response.statusCode == 204 else {
                throw NetworkCommunicatorError.payloadError(.emptyData)
            }
            return .success(nil)
        }
        return try decodeSuccess(response: response)
    }

    private func decodeSuccess<ResponseType: Decodable>(response: ServerResponse) throws -> Result<ResponseType, Never> {
        guard ResponseType.self != EmptyNetworkResponse.self else {
            let emptyResponse: ResponseType = EmptyNetworkResponse() as! ResponseType
            return .success(emptyResponse)
        }
        guard let payload = response.payload else {
            throw NetworkCommunicatorError.payloadError(.emptyData)
        }
        guard ResponseType.self != RawServerResponse.self else {
            let message = String(data: payload, encoding: .utf8) ?? ""
            let rawResponse = RawServerResponse(data: message) as! ResponseType
            return .success(rawResponse)
        }
        let decodedResponse: ResponseType
        do {
            decodedResponse = try self.jsonDecoder.decode(ResponseType.self, from: payload)
        } catch let decodingError {
            Logger.shared.error(response.response.url!.absoluteString)
            Logger.shared.debug("Payload decoding error '\(String(describing: ResponseType.self))': \(decodingError)")
            let message = String(data: payload, encoding: .utf8) ?? ""
            Logger.shared.debug("Message: \(message)")
            throw NetworkCommunicatorError.payloadError(.badData(rawPayload: message))

        }
        return .success(decodedResponse)
    }
}

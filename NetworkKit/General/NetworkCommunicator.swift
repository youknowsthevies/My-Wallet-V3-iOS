//
//  NetworkCommunicator.swift
//  Blockchain
//
//  Created by Jack on 07/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import ToolKit
import DIKit

public protocol NetworkCommunicatorAPI {
    
    func perform(request: NetworkRequest) -> Completable
    
    func perform<ResponseType: Decodable>(request: NetworkRequest, responseType: ResponseType.Type) -> Completable
    
    func perform<ResponseType: Decodable, ErrorResponseType: Error & Decodable>(request: NetworkRequest, responseType: ResponseType.Type, errorResponseType: ErrorResponseType.Type) -> Single<Result<ResponseType, ErrorResponseType>>
    
    func perform<ResponseType: Decodable>(request: NetworkRequest, responseType: ResponseType.Type) -> Single<ResponseType>
    
    func perform<ResponseType: Decodable>(request: NetworkRequest) -> Single<ResponseType>
    
    func performOptional<ResponseType: Decodable>(request: NetworkRequest, responseType: ResponseType.Type) -> Single<ResponseType?>
}

final class NetworkCommunicator: NetworkCommunicatorAPI {
    
    private var eventRecorder: AnalyticsEventRecording?
    private var authenticator: AuthenticatorAPI?
    
    private let scheduler: ConcurrentDispatchQueueScheduler
    private let session: URLSession
    private let sessionHandler: NetworkSessionDelegateAPI
    
    init(session: URLSession = resolve(),
         sessionDelegate: SessionDelegateAPI = resolve(),
         sessionHandler: NetworkSessionDelegateAPI = resolve(),
         scheduler: ConcurrentDispatchQueueScheduler = resolve(tag: DIKitContext.network),
         eventRecorder: AnalyticsEventRecording? = nil,
         authenticator: AuthenticatorAPI? = nil) {
        self.session = session
        self.sessionHandler = sessionHandler
        self.scheduler = scheduler
        self.eventRecorder = eventRecorder
        self.authenticator = authenticator

        sessionDelegate.delegate = sessionHandler
    }
    
    // MARK: - NetworkCommunicatorAPI
    
    func perform(request: NetworkRequest) -> Completable {
        perform(request: request, responseType: EmptyNetworkResponse.self)
    }
    
    func perform<ResponseType: Decodable>(request: NetworkRequest, responseType: ResponseType.Type) -> Completable {
        let requestSingle: Single<ResponseType> = executeAndHandleAuth(request: request)
        return requestSingle.asCompletable()
    }
    
    func performOptional<ResponseType: Decodable>(request: NetworkRequest, responseType: ResponseType.Type) -> Single<ResponseType?> {
        executeAndHandleAuth(request: request)
    }

    @available(*, deprecated, message: "Don't use this")
    func perform<ResponseType: Decodable, ErrorResponseType: Error & Decodable>(request: NetworkRequest, responseType: ResponseType.Type, errorResponseType: ErrorResponseType.Type) -> Single<Result<ResponseType, ErrorResponseType>> {
        guard request.authenticated else {
            return privatePerform(request: request)
        }
        guard let authenticator = authenticator else {
            fatalError("Authenticator missing")
        }
        return authenticator.authenticateWithResult { [weak self] token in
            guard let self = self else {
                return Single.error(ToolKitError.nullReference(Self.self))
            }
            var request = request
            request.add(authenticationToken: token)
            return self.privatePerform(request: request)
        }
    }
    
    func perform<ResponseType: Decodable>(request: NetworkRequest, responseType: ResponseType.Type) -> Single<ResponseType> {
        executeAndHandleAuth(request: request)
    }
    
    func perform<ResponseType: Decodable>(request: NetworkRequest) -> Single<ResponseType> {
        executeAndHandleAuth(request: request)
    }
    
    // MARK: - Private methods
    
    private func executeAndHandleAuth<ResponseType: Decodable>(request: NetworkRequest) -> Single<ResponseType> {
        guard request.authenticated else {
            return privatePerform(request: request)
        }
        guard let authenticator = authenticator else {
            fatalError("Authenticator missing")
        }
        return authenticator.authenticate { [weak self] token in
            guard let self = self else {
                return Single.error(ToolKitError.nullReference(Self.self))
            }
            var request = request
            request.add(authenticationToken: token)
            return self.privatePerform(request: request)
        }
    }
    
    private func privatePerform<ResponseType: Decodable, ErrorResponseType: Error & Decodable>(request: NetworkRequest) -> Single<Result<ResponseType, ErrorResponseType>> {
        execute(request: request)
            .recordErrors(on: eventRecorder, request: request) { request, error -> AnalyticsEvent? in
                error.analyticsEvent(for: request) { serverErrorResponse in
                    request.decoder.decodeFailureToString(errorResponse: serverErrorResponse)
                }
            }
            .mapRawServerError()
            .decode(with: request.decoder)
    }
    
    private func privatePerform<ResponseType: Decodable>(request: NetworkRequest) -> Single<ResponseType> {
        execute(request: request)
            .recordErrors(on: eventRecorder, request: request) { request, error -> AnalyticsEvent? in
                error.analyticsEvent(for: request) { serverErrorResponse in
                    request.decoder.decodeFailureToString(errorResponse: serverErrorResponse)
                }
            }
            .mapRawServerError()
            .decode(with: request.decoder)
    }
        
    // swiftlint:disable:next function_body_length
    private func execute(request: NetworkRequest) -> Single<
        Result<ServerResponse, NetworkCommunicatorError>
    > {
        Single<Result<ServerResponse, NetworkCommunicatorError>>.create(weak: self) { (self, observer) -> Disposable in
            let urlRequest = request.URLRequest
            let requestPath = urlRequest.url?.path ?? ""

            Logger.shared.debug("URL: \(urlRequest.url?.absoluteString ?? "")")

            let task = self.session.dataTask(with: urlRequest) { payload, response, error in
                guard let response = response as? HTTPURLResponse else {
                    Logger.shared.debug("\(requestPath) failed with error: \(error?.localizedDescription ?? "nil")")
                    observer(.success(.failure(NetworkCommunicatorError.serverError(.badResponse))))
                    return
                }
//                #if DEBUG
//                if let payload = payload, let responseValue = String(data: payload, encoding: .utf8) {
//                    Logger.shared.debug("\(responseValue) <- \(requestPath)")
//                }
//                #endif
                switch response.statusCode {
                case 204:
                    observer(.success(.success(ServerResponse(response: response, payload: nil))))
                    return
                case 200...299:
                    observer(.success(.success(ServerResponse(response: response, payload: payload))))
                    return
                default:
                    Logger.shared.debug("\(requestPath) failed with status code: \(response.statusCode)")
                    observer(.success(.failure(NetworkCommunicatorError.rawServerError(ServerErrorResponse(response: response, payload: payload)))))
                    return
                }
            }
            defer {
                task.resume()
            }
            return Disposables.create {
                task.cancel()
            }
        }
        .subscribeOn(scheduler)
        .observeOn(scheduler)
    }
}

extension PrimitiveSequence where Trait == SingleTrait, Element == Result<ServerResponse, NetworkCommunicatorError> {
    fileprivate func recordErrors(on recorder: AnalyticsEventRecording?, request: NetworkRequest, errorMapper: @escaping (NetworkRequest, NetworkCommunicatorError) -> AnalyticsEvent?) -> Single<Element> {
        guard request.recordErrors else { return self }
        return self.do(onSuccess: { result in
                guard case .failure(let error) = result else {
                    return
                }
                guard let event = errorMapper(request, error) else {
                    return
                }
                recorder?.record(event: event)
            })
            .do(onError: { error in
                guard let error = error as? NetworkCommunicatorError else {
                    return
                }
                guard let event = errorMapper(request, error) else {
                    return
                }
                recorder?.record(event: event)
            })
    }
}

extension PrimitiveSequence where Trait == SingleTrait, Element == Result<ServerResponse, NetworkCommunicatorError> {
    fileprivate func mapRawServerError() -> Single<Result<ServerResponse, ServerErrorResponse>> {
        map { result -> Result<ServerResponse, ServerErrorResponse> in
            switch result {
            case .success(let networkResponse):
                return .success(networkResponse)
            case .failure(let error):
                guard case .rawServerError(let serverErrorResponse) = error else {
                    throw error
                }
                return .failure(serverErrorResponse)
            }
        }
    }
}

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

public protocol NetworkCommunicatorAPI {
    
    func perform(request: NetworkRequest) -> Completable
    
    func perform<ResponseType: Decodable>(request: NetworkRequest, responseType: ResponseType.Type) -> Completable
    
    func perform<ResponseType: Decodable, ErrorResponseType: Error & Decodable>(request: NetworkRequest, responseType: ResponseType.Type, errorResponseType: ErrorResponseType.Type) -> Single<Result<ResponseType, ErrorResponseType>>
    
    func perform<ResponseType: Decodable>(request: NetworkRequest, responseType: ResponseType.Type) -> Single<ResponseType>
    
    func perform<ResponseType: Decodable>(request: NetworkRequest) -> Single<ResponseType>
    func performOptional<ResponseType: Decodable>(request: NetworkRequest, responseType: ResponseType.Type) -> Single<ResponseType?>
}

final public class NetworkCommunicator: NetworkCommunicatorAPI, AnalyticsEventRecordable & Authenticatable {
    
    public static let shared = Network.Dependencies.default.communicator
    
    private var eventRecorder: AnalyticsEventRecording?
    private var authenticator: AuthenticatorAPI?
    
    private let scheduler: ConcurrentDispatchQueueScheduler
    private let session: URLSession
    private let sessionHandler: NetworkSessionDelegateAPI
    
    init(session: URLSession,
         sessionDelegate: SessionDelegateAPI,
         sessionHandler: NetworkSessionDelegateAPI = NetworkCommunicatorSessionHandler(),
         scheduler: ConcurrentDispatchQueueScheduler = ConcurrentDispatchQueueScheduler(qos: .background)) {
        self.session = session
        self.sessionHandler = sessionHandler
        self.scheduler = scheduler
        
        sessionDelegate.delegate = sessionHandler
    }
    
    // MARK: - Recordable
    
    public func use(eventRecorder: AnalyticsEventRecording) {
        self.eventRecorder = eventRecorder
    }
    
    // MARK: - Authenticator
    
    public func use(authenticator: AuthenticatorAPI) {
        self.authenticator = authenticator
    }
    
    // MARK: - NetworkCommunicatorAPI
    
    public func perform(request: NetworkRequest) -> Completable {
        perform(request: request, responseType: EmptyNetworkResponse.self)
    }
    
    public func perform<ResponseType: Decodable>(request: NetworkRequest, responseType: ResponseType.Type) -> Completable {
        let requestSingle: Single<ResponseType> = executeAndHandleAuth(request: request)
        return requestSingle.asCompletable()
    }
    
    public func performOptional<ResponseType: Decodable>(request: NetworkRequest, responseType: ResponseType.Type) -> Single<ResponseType?> {
        executeAndHandleAuth(request: request)
    }

    @available(*, deprecated, message: "Don't use this")
    public func perform<ResponseType: Decodable, ErrorResponseType: Error & Decodable>(request: NetworkRequest, responseType: ResponseType.Type, errorResponseType: ErrorResponseType.Type) -> Single<Result<ResponseType, ErrorResponseType>> {
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
    
    public func perform<ResponseType: Decodable>(request: NetworkRequest, responseType: ResponseType.Type) -> Single<ResponseType> {
        executeAndHandleAuth(request: request)
    }
    
    public func perform<ResponseType: Decodable>(request: NetworkRequest) -> Single<ResponseType> {
        executeAndHandleAuth(request: request)
    }
    
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
        return execute(request: request)
            .recordErrors(on: eventRecorder, request: request) { request, error -> AnalyticsEvent? in
                error.analyticsEvent(for: request) { serverErrorResponse in
                    request.decoder.decodeFailureToString(errorResponse: serverErrorResponse)
                }
            }
            .mapRawServerError()
            .decode(with: request.decoder)
    }
    
    private func privatePerform<ResponseType: Decodable>(request: NetworkRequest) -> Single<ResponseType> {
        return execute(request: request)
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

            Logger.shared.debug("URLRequest.URL: \(String(describing: urlRequest.url))")

            let task = self.session.dataTask(with: urlRequest) { payload, response, error in
                guard let httpResponse = response as? HTTPURLResponse else {
                    observer(.success(.failure(NetworkCommunicatorError.serverError(.badResponse))))
                    return
                }
//                if let payload = payload, let responseValue = String(data: payload, encoding: .utf8) {
////                    Logger.shared.debug("\(responseValue) <- \(response?.url?.path ?? "")")
//                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    observer(.success(.failure(NetworkCommunicatorError.rawServerError(ServerErrorResponse(response: httpResponse, payload: payload)))))
                    return
                }
                if httpResponse.statusCode == 204 {
                    observer(.success(.success(ServerResponse(response: httpResponse, payload: nil))))
                    return
                }
                observer(.success(.success(ServerResponse(response: httpResponse, payload: payload))))
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

class NetworkCommunicatorSessionHandler: NetworkSessionDelegateAPI {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping AuthChallengeHandler) {
        guard BlockchainAPI.shared.shouldPinCertificate else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        let host = challenge.protectionSpace.host
        Logger.shared.info("Received challenge from \(host)")
        
        if BlockchainAPI.PartnerHosts.allCases.contains(where: { $0.rawValue == host }) {
            completionHandler(.performDefaultHandling, nil)
        } else {
            CertificatePinner.shared.didReceive(challenge, completion: completionHandler)
        }
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

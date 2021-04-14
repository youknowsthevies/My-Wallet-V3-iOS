//
//  NetworkCommunicatorNew.swift
//  NetworkKit
//
//  Created by Jack Pooley on 25/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Combine
import DIKit
import ToolKit

protocol NetworkCommunicatorNewAPI {
    
    /// Performs network requests
    /// - Parameter request: the request object describes the network request to be performed
    func dataTaskPublisher(
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponseNew, NetworkCommunicatorErrorNew>
}

final class NetworkCommunicatorNew: NetworkCommunicatorNewAPI {
    
    // MARK: - Private properties
    
    private let session: NetworkSession
    private let scheduler: DispatchQueue
    private let authenticator: AuthenticatorNewAPI?
    private let eventRecorder: AnalyticsEventRecording?
    
    // MARK: - Setup
    
    init(session: NetworkSession = resolve(),
         sessionDelegate: SessionDelegateAPI = resolve(),
         sessionHandler: NetworkSessionDelegateAPI = resolve(),
         scheduler: DispatchQueue = DispatchQueue.global(qos: .background),
         authenticator: AuthenticatorNewAPI? = nil,
         eventRecorder: AnalyticsEventRecording? = nil) {
        self.session = session
        self.scheduler = scheduler
        self.authenticator = authenticator
        self.eventRecorder = eventRecorder
        
        sessionDelegate.delegate = sessionHandler
    }
    
    // MARK: - Internal methods
    
    func dataTaskPublisher(
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponseNew, NetworkCommunicatorErrorNew> {
        guard request.authenticated else {
            return execute(request: request)
        }
        // TODO: remove this once we are using this communicator for authenticated calls
        unimplemented()
        guard let authenticator = authenticator else {
            fatalError("Authenticator missing")
        }
        return authenticator
            .authenticate { [weak self] token in
                guard let self = self else {
                    let empty = Empty(
                        completeImmediately: true,
                        outputType: ServerResponseNew.self,
                        failureType: NetworkCommunicatorErrorNew.self
                    )
                    return empty.eraseToAnyPublisher()
                }
                var request = request
                request.add(authenticationToken: token)
                return self.execute(request: request)
            }
    }
    
    // MARK: - Private methods
    
    private func execute(
        request: NetworkRequest
    ) -> AnyPublisher<ServerResponseNew, NetworkCommunicatorErrorNew> {
        session.erasedDataTaskPublisher(for: request.URLRequest)
            .mapError(NetworkCommunicatorErrorNew.urlError)
            .flatMap { elements -> AnyPublisher<ServerResponseNew, NetworkCommunicatorErrorNew> in
                request.responseHandler.handle(elements: elements, for: request)
            }
            .eraseToAnyPublisher()
            .recordErrors(on: eventRecorder, request: request) { request, error -> AnalyticsEvent? in
                error.analyticsEvent(for: request) { serverErrorResponse in
                    request.decoder.decodeFailureToString(errorResponse: serverErrorResponse)
                }
            }
            .subscribe(on: scheduler)
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }
}

protocol NetworkSession {
    
    func erasedDataTaskPublisher(
        for request: URLRequest
    ) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}

extension URLSession: NetworkSession {
    
    func erasedDataTaskPublisher(
        for request: URLRequest
    ) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        dataTaskPublisher(for: request)
            .eraseToAnyPublisher()
    }
}

extension AnyPublisher where Output == ServerResponseNew,
                             Failure == NetworkCommunicatorErrorNew {
    
    fileprivate func recordErrors(
        on recorder: AnalyticsEventRecording?,
        request: NetworkRequest,
        errorMapper: @escaping (NetworkRequest, NetworkCommunicatorErrorNew) -> AnalyticsEvent?
    ) -> AnyPublisher<ServerResponseNew, NetworkCommunicatorErrorNew> {
        handleEvents(
            receiveCompletion: { completion in
                guard case .failure(let communicatorError) = completion else {
                    return
                }
                guard let event = errorMapper(request, communicatorError) else {
                    return
                }
                recorder?.record(event: event)
            }
        )
        .eraseToAnyPublisher()
    }
}

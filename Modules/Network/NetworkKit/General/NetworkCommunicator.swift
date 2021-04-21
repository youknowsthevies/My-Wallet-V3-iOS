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

protocol NetworkCommunicatorAPI {
    
    /// Performs network requests
    /// - Parameter request: the request object describes the network request to be performed
    func dataTaskPublisher(
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkCommunicatorError>
}

final class NetworkCommunicator: NetworkCommunicatorAPI {
    
    // MARK: - Private properties
    
    private let session: NetworkSession
    private let queue: DispatchQueue
    private let authenticator: AuthenticatorAPI?
    private let eventRecorder: AnalyticsEventRecording?
    
    // MARK: - Setup
    
    init(session: NetworkSession = resolve(),
         sessionDelegate: SessionDelegateAPI = resolve(),
         sessionHandler: NetworkSessionDelegateAPI = resolve(),
         queue: DispatchQueue = DispatchQueue.global(qos: .background),
         authenticator: AuthenticatorAPI? = nil,
         eventRecorder: AnalyticsEventRecording? = nil) {
        self.session = session
        self.queue = queue
        self.authenticator = authenticator
        self.eventRecorder = eventRecorder
        
        sessionDelegate.delegate = sessionHandler
    }
    
    // MARK: - Internal methods
    
    func dataTaskPublisher(
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkCommunicatorError> {
        guard request.authenticated else {
            return execute(request: request)
        }
        guard let authenticator = authenticator else {
            fatalError("Authenticator missing")
        }
        return authenticator
            .authenticate { [weak self] token in
                guard let self = self else {
                    let empty = Empty(
                        completeImmediately: true,
                        outputType: ServerResponse.self,
                        failureType: NetworkCommunicatorError.self
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
    ) -> AnyPublisher<ServerResponse, NetworkCommunicatorError> {
        session.erasedDataTaskPublisher(for: request.URLRequest)
            .mapError(NetworkCommunicatorError.urlError)
            .flatMap { elements -> AnyPublisher<ServerResponse, NetworkCommunicatorError> in
                request.responseHandler.handle(elements: elements, for: request)
            }
            .eraseToAnyPublisher()
            .recordErrors(on: eventRecorder, request: request) { request, error -> AnalyticsEvent? in
                error.analyticsEvent(for: request) { serverErrorResponse in
                    request.decoder.decodeFailureToString(errorResponse: serverErrorResponse)
                }
            }
            .subscribe(on: queue)
            .receive(on: queue)
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

extension AnyPublisher where Output == ServerResponse,
                             Failure == NetworkCommunicatorError {
    
    fileprivate func recordErrors(
        on recorder: AnalyticsEventRecording?,
        request: NetworkRequest,
        errorMapper: @escaping (NetworkRequest, NetworkCommunicatorError) -> AnalyticsEvent?
    ) -> AnyPublisher<ServerResponse, NetworkCommunicatorError> {
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

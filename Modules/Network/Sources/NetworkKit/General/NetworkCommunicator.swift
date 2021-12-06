// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import Foundation
import NetworkError
import ToolKit

#if DEBUG || ALPHA_BUILD || INTERNAL_BUILD
import PulseCore
#endif

public protocol NetworkCommunicatorAPI {

    /// Performs network requests
    /// - Parameter request: the request object describes the network request to be performed
    func dataTaskPublisher(
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError>
}

final class NetworkCommunicator: NetworkCommunicatorAPI {

    // MARK: - Private properties

    private let session: NetworkSession
    private let authenticator: AuthenticatorAPI?
    private let eventRecorder: AnalyticsEventRecorderAPI?

    // MARK: - Setup

    init(
        session: NetworkSession = resolve(),
        sessionDelegate: SessionDelegateAPI = resolve(),
        sessionHandler: NetworkSessionDelegateAPI = resolve(),
        authenticator: AuthenticatorAPI? = nil,
        eventRecorder: AnalyticsEventRecorderAPI? = nil
    ) {
        self.session = session
        self.authenticator = authenticator
        self.eventRecorder = eventRecorder

        sessionDelegate.delegate = sessionHandler
    }

    // MARK: - Internal methods

    func dataTaskPublisher(
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        guard request.authenticated else {
            return execute(request: request)
        }
        guard let authenticator = authenticator else {
            fatalError("Authenticator missing")
        }
        let _execute = execute
        return authenticator
            .authenticate { [execute = _execute] token in
                execute(request.adding(authenticationToken: token))
            }
    }

    // MARK: - Private methods

    private func execute(
        request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        session.erasedDataTaskPublisher(
            for: request.peek("🌎", \.urlRequest.cURLCommand, if: \.isDebugging.request).urlRequest
        )
        .handleEvents(
            receiveOutput: { data, response in
                #if DEBUG || ALPHA_BUILD || INTERNAL_BUILD
                LoggerStore.default.storeRequest(
                    request.urlRequest,
                    response: response,
                    error: nil,
                    data: data,
                    metrics: nil
                )
                #endif
            },
            receiveCompletion: { completion in
                #if DEBUG || ALPHA_BUILD || INTERNAL_BUILD
                guard case .failure(let error) = completion else {
                    return
                }
                LoggerStore.default.storeRequest(
                    request.urlRequest,
                    response: nil,
                    error: error,
                    data: nil,
                    metrics: nil
                )
                #endif
            }
        )
        .mapError(NetworkError.urlError)
        .flatMap { elements -> AnyPublisher<ServerResponse, NetworkError> in
            request.responseHandler.handle(elements: elements, for: request)
        }
        .eraseToAnyPublisher()
        .recordErrors(on: eventRecorder, request: request) { request, error -> AnalyticsEvent? in
            error.analyticsEvent(for: request) { serverErrorResponse in
                request.decoder.decodeFailureToString(errorResponse: serverErrorResponse)
            }
        }
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
    Failure == NetworkError
{

    fileprivate func recordErrors(
        on recorder: AnalyticsEventRecorderAPI?,
        request: NetworkRequest,
        errorMapper: @escaping (NetworkRequest, NetworkError) -> AnalyticsEvent?
    ) -> AnyPublisher<ServerResponse, NetworkError> {
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

#if DEBUG
public class ReplayNetworkCommunicator: NetworkCommunicatorAPI {

    public struct Key: Hashable {

        public let url: URL
        public let method: String

        var filePath: String

        init(_ request: URLRequest, in directory: String) {
            self.init(
                request,
                __filePath(
                    for: request,
                    method: request.httpMethod.or(default: "GET"),
                    in: directory
                ).path
            )
        }

        init(_ request: URLRequest, in bundle: Bundle) {
            self.init(
                request,
                __filePath(
                    for: request,
                    method: request.httpMethod.or(default: "GET"),
                    in: bundle.resourcePath!
                ).lastPathComponent
            )
        }

        init(_ request: URLRequest, _ path: String) {
            url = request.url!
            method = request.httpMethod.or(default: "GET")
            filePath = path
        }
    }

    public var data: LazyDictionary<Key, Data?>

    public private(set) var requests: [NetworkRequest] = []

    private var errors: [Key: URLError.Code] = [:]
    private let makeKey: (URLRequest) -> Key

    public init(_ data: [URLRequest: Data], in bundle: Bundle) {
        let makeKey = { Key($0, in: bundle) }
        let sanitized = data.reduce(into: [:]) { result, x in
            result[makeKey(x.key)] = x.value
        }
        self.data = .init(sanitized) { request in
            try? Data(contentsOf: bundle.resourceURL!.appendingPathComponent(request.filePath))
        }
        self.makeKey = makeKey
    }

    public init(_ data: [URLRequest: Data], in directory: String = NSTemporaryDirectory()) {
        let makeKey = { Key($0, in: directory) }
        let sanitized = data.reduce(into: [:]) { result, x in
            result[makeKey(x.key)] = x.value
        }
        self.data = .init(sanitized) { request in
            try? Data(contentsOf: URL(fileURLWithPath: request.filePath))
        }
        self.makeKey = makeKey
    }

    public subscript(request: URLRequest) -> Data? {
        get { data[makeKey(request)] }
        set { data[makeKey(request)] = newValue }
    }

    public subscript(request: NetworkRequest) -> Data? {
        get { self[request.urlRequest] }
        set { self[request.urlRequest] = newValue }
    }

    public func error(_ request: URLRequest) {
        errors[makeKey(request)] = .badServerResponse
    }

    public func dataTaskPublisher(
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        let key = makeKey(request.urlRequest)
        if let code = errors[makeKey(request.urlRequest)] {
            return Fail(error: .urlError(URLError(code))).eraseToAnyPublisher()
        }
        requests.append(request)
        guard
            let url = request.urlRequest.url,
            let value = data[key]
        else {
            return Fail(
                error: .urlError(URLError(.unsupportedURL))
            ).eraseToAnyPublisher()
        }
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: [:]
        )!
        return Just(ServerResponse(payload: value, response: response))
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
}

extension ReplayNetworkCommunicator.Key {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.url == rhs.url && lhs.method == rhs.method
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(method)
    }
}

public class EphemeralNetworkCommunicator: NetworkCommunicatorAPI {

    public var session: URLSession
    public var isRecording: Bool
    public var directory: String
    public var responseHandler: NetworkResponseHandlerAPI = NetworkResponseHandler()

    public init(
        session: URLSession = .shared,
        isRecording: Bool = false,
        directory: String = NSTemporaryDirectory()
    ) {
        self.session = session
        self.isRecording = isRecording
        self.directory = directory
    }

    public func dataTaskPublisher(
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        session.erasedDataTaskPublisher(
            for: request.peek("🌎", \.urlRequest.cURLCommand).urlRequest
        )
        .handleEvents(receiveOutput: { [weak self] data, _ in
            guard let self = self else { return }
            if self.isRecording {
                let request = request.urlRequest
                do {
                    let filePath = __filePath(for: request, method: request.httpMethod, in: self.directory)
                    try FileManager.default.createDirectory(
                        at: filePath.deletingLastPathComponent(),
                        withIntermediateDirectories: true,
                        attributes: [:]
                    )
                    try data.write(
                        to: filePath,
                        options: .atomicWrite
                    )
                } catch {
                    assertionFailure("‼️ Failed to write \(request) because \(error)")
                }
            }
        })
        .mapError(NetworkError.urlError)
        .flatMap { [responseHandler] elements -> AnyPublisher<ServerResponse, NetworkError> in
            responseHandler.handle(elements: elements, for: request)
        }
        .eraseToAnyPublisher()
    }
}

private func __filePath(for request: URLRequest, method: String?, in directory: String) -> URL {
    var filePath = __filePath(for: request.url!, method: method, in: directory)
    if request.value(forHTTPHeaderField: "Accept") == "application/json" {
        filePath.appendPathExtension("json")
    }
    return filePath
}

private func __filePath(for url: URL, method: String?, in directory: String) -> URL {
    let filePath = URL(fileURLWithPath: directory)
        .appendingPathComponent(method.or(default: "GET"))
        .appendingPathComponent(url.path)
        .appendingPathComponent(
            url.queryArgs
                .reduce(into: "") { string, next in
                    string.append("/\(next.key)/\(next.value)")
                }
        )

    return filePath
        .appendingPathComponent(
            filePath.path
                .dropPrefix(directory)
                .dropPrefix("/")
                .dropSuffix("/")
                .replacingOccurrences(of: "/", with: "_")
        )
}

#endif

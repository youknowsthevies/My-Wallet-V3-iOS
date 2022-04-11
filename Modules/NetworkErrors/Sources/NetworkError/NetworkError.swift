// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A networking error returned by the network layer, this can be mapped to user facing errors at a high level
public enum NetworkError: Error {
    case urlError(URLError)
    case serverError(HTTPRequestServerError)
    case rawServerError(ServerErrorResponse)
    case payloadError(HTTPRequestPayloadError)
    case authentication(Error)
}

extension NetworkError: FromNetworkError {

    public static func from(_ networkError: NetworkError) -> NetworkError {
        networkError
    }
}

/// A simple implementation of `Equatable` for now. I might make sense to improve this, eventually.
extension NetworkError: Equatable {

    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        String(describing: lhs) == String(describing: rhs)
    }
}

extension NetworkError: CustomStringConvertible {

    public var endpoint: String? {
        switch self {
        case .authentication, .urlError, .payloadError, .serverError:
            return nil
        case .rawServerError(let error):
            return error.response.url?.path
        }
    }

    public var response: HTTPURLResponse? {
        switch self {
        case .authentication, .payloadError, .serverError, .urlError:
            return nil
        case .rawServerError(let error):
            return error.response
        }
    }

    public var code: Int? {
        switch self {
        case .authentication, .payloadError, .serverError:
            return nil
        case .urlError(let error):
            return error.errorCode
        case .rawServerError(let error):
            return error.response.statusCode
        }
    }

    public var description: String {
        switch self {
        case .authentication(let error), .urlError(let error as Error):
            return error.localizedDescription
        case .payloadError(let error as Error), .serverError(let error as Error):
            return String(describing: error)
        case .rawServerError(let error):
            do {
                guard let payload = error.payload else { throw error }
                guard let string = String(data: payload, encoding: .utf8) else { throw error }
                return
                    """
                    HTTP \(error.response.statusCode)
                    \(string)
                    """
            } catch _ {
                return
                    """
                    HTTP \(error.response.statusCode)
                    """
            }
        }
    }
}

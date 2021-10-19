// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol InternetReachabilityAPI: AnyObject {
    var canConnect: Bool { get }
}

public enum InternetReachabilityError: Error {
    case internetUnreachable
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

/// Interace that exposes local JWT token that will embeded in request's Authorization header.
/// This is used by backend to identify logged in user.
public protocol TokenRepositoryAPI {
    var token: String? { get }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

/// A closure that provides local JWT token which will embeded in the request's Authorization header.
public typealias TokenProvider = () -> String?

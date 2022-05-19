// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A `protocol` for remote trace implementations to conform to
public protocol RemoteTrace {

    /// Stop the trace if active
    func stop()
}

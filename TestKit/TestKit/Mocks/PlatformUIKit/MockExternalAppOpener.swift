// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformUIKit

public final class MockExternalAppOpener: ExternalAppOpener {

    public struct RecordedInvocations {
        public var open: [(url: URL, completionHandler: (Bool) -> Void)] = []
    }

    public private(set) var recordedInvocations = RecordedInvocations()

    public func open(_ url: URL, completionHandler: @escaping (Bool) -> Void) {
        recordedInvocations.open.append((url, completionHandler))
    }
}

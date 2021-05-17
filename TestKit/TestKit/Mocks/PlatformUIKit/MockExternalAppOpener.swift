// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformUIKit

public final class MockExternalAppOpener: ExternalAppOpener {
    
    public struct RecordedInvocations {
        public var open: [(url: URL, completionHandler: (Bool) -> ())] = []
    }
    
    private(set) public var recordedInvocations = RecordedInvocations()
    
    public func open(_ url: URL, completionHandler: @escaping (Bool) -> ()) {
        recordedInvocations.open.append((url, completionHandler))
    }
}

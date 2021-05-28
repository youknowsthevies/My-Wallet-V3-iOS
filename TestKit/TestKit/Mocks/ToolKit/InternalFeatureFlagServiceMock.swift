// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

final class InternalFeatureFlagServiceMock: InternalFeatureFlagServiceAPI {
    var underlyingIsEnabled: Bool = false
    func isEnabled(_ feature: InternalFeature) -> Bool {
        underlyingIsEnabled
    }

    func enable(_ feature: InternalFeature) { }

    func enable(_ features: [InternalFeature]) { }

    func disable(_ feature: InternalFeature) { }
}

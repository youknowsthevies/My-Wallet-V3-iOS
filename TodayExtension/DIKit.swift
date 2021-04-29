// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import ToolKit

extension DependencyContainer {
    
    // MARK: - Today Extension Module
    
    static var today = module {
        
        factory { AnalyticsServiceMock() as AnalyticsServiceProviding }
        
        factory { UIDevice.current as DeviceInfo }
    }
}

extension UIDevice: DeviceInfo {
    public var uuidString: String {
        UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
}

final class AnalyticsServiceMock: AnalyticsServiceProviding {
    func trackEvent(title: String, parameters: [String : Any]?) {
        // NOOP
    }
}

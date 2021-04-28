//
//  DIKit.swift
//  TodayExtension
//
//  Created by Alex McGregor on 8/4/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import PlatformUIKit
import ToolKit

extension DependencyContainer {
    
    // MARK: - Today Extension Module
    
    static var today = module {
        
        factory { AnalyticsServiceMock() as AnalyticsServiceAPI }
        
        factory { UIDevice.current as DeviceInfo }
    }
}

extension UIDevice: DeviceInfo {
    public var uuidString: String {
        UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
}

final class AnalyticsServiceMock: AnalyticsServiceAPI {
    func trackEvent(title: String, parameters: [String : Any]?) {
        // NOOP
    }
}

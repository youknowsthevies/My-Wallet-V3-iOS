//
//  DIKit.swift
//  ToolKit
//
//  Created by Jack Pooley on 24/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit

extension DependencyContainer {
    
    // MARK: - ToolKit Module
     
    public static var analyticsKit = module {
        
        single { AnalyticsEventRecorder() as AnalyticsEventRecorderAPI }
        
        factory { () -> AnalyticsEventRecording in
            let recorder: AnalyticsEventRecorderAPI = DIKit.resolve()
            return recorder as AnalyticsEventRecording
        }
        
        factory { () -> AnalyticsEventRelayRecording in
            let recorder: AnalyticsEventRecorderAPI = DIKit.resolve()
            return recorder as AnalyticsEventRelayRecording
        }

    }
}

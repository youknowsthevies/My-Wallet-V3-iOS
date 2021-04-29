// Copyright © Blockchain Luxembourg S.A. All rights reserved.

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

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import NabuAnalyticsKit

extension DependencyContainer {
    
    // MARK: - NabuAnalyticsDataKit Module
     
    public static var nabuAnalyticsDataKit = module {
        
        factory { APIClient() as EventSendingAPI }

        single { AnalyticsEventsRepository() as AnalyticsEventsRepositoryAPI }
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

extension DependencyContainer {
    
    // MARK: - NabuAnalyticsKit Module
     
    public static var nabuAnalyticsKit = module {
        
        single { AnalyticsEventService() as AnalyticsEventServiceAPI }
        
        single { ContextProvider() as ContextProviding }
        
        single { TokenProvider() as TokenProviding }
    }
}

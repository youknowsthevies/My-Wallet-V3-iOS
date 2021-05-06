// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

extension DependencyContainer {
     
    public static var nabuAnalyticsKit = module {
        
        single { ContextProvider() as ContextProviding }
        
        single { APIClient() as EventSendingAPI }
    }
    
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

extension DependencyContainer {
     
    public static var nabuAnalyticsKit = module {
        
        single { APIClient() as EventSendingAPI }
        
        single { ContextProvider() as ContextProviding }
    }
}

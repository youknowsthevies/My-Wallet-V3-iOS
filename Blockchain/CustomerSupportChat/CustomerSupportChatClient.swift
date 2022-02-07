// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Intercom
import Localization
import PlatformKit
import PlatformUIKit
import ToolKit

enum CustomerSupportChatClientError: Error {
    case chatProviderSDKError(Error)
}

protocol CustomerSupportChatClientAPI {
    func setupWithAccountKey(_ key: String, applicationId: String)
    func presentMessagingScreenWithVisitorInfo(
        _ visitorInfo: VisitorInformation
    )
}

final class CustomerSupportChatClient: CustomerSupportChatClientAPI {

    func setupWithAccountKey(
        _ key: String,
        applicationId: String
    ) {
        Intercom.setApiKey(key, forAppId: applicationId)
    }

    func presentMessagingScreenWithVisitorInfo(
        _ visitorInfo: VisitorInformation
    ) {
        Intercom.registerUser(
            withUserId: visitorInfo.identifier,
            email: visitorInfo.email
        )
        Intercom.presentMessenger()
    }
}

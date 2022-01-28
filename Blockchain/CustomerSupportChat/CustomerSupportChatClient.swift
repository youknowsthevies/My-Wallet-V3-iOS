// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import ToolKit

enum CustomerSupportChatClientError: Error {
    case chatProviderSDKError(Error)
}

protocol CustomerSupportChatClientAPI {
    func setupWithAccountKey(_ key: String)
    func buildMessagingScreenWithVisitorInfo(
        _ visitorInfo: VisitorInformation,
        department: CustomerSupportDepartment
    ) -> Result<UIViewController, CustomerSupportChatClientError>
}

final class CustomerSupportChatClient: CustomerSupportChatClientAPI {

    private typealias LocalizationIds = LocalizationConstants.CustomerSupport

    func setupWithAccountKey(_ key: String) {
        // no-op
    }

    func buildMessagingScreenWithVisitorInfo(
        _ visitorInfo: VisitorInformation,
        department: CustomerSupportDepartment
    ) -> Result<UIViewController, CustomerSupportChatClientError> {
        unimplemented()
    }
}

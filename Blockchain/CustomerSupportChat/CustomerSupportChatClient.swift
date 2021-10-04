// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ChatProvidersSDK
import ChatSDK
import Combine
import CommonUISDK
import DIKit
import Localization
import MessagingSDK
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
        Chat.initialize(accountKey: key)
        CommonTheme.currentTheme.primaryColor = .brandPrimary
    }

    func buildMessagingScreenWithVisitorInfo(
        _ visitorInfo: VisitorInformation,
        department: CustomerSupportDepartment
    ) -> Result<UIViewController, CustomerSupportChatClientError> {
        let chatConfiguration = ChatConfiguration()
        chatConfiguration.isPreChatFormEnabled = true
        chatConfiguration.chatMenuActions = [.endChat]
        let chatAPIConfiguration = ChatAPIConfiguration()
        let messageConfiguration = MessagingConfiguration()
        messageConfiguration.name = LocalizationIds.name
        chatAPIConfiguration.department = department.rawValue
        chatAPIConfiguration.visitorInfo = VisitorInfo(
            name: visitorInfo.name,
            email: visitorInfo.email,
            phoneNumber: ""
        )

        Chat.instance?.configuration = chatAPIConfiguration

        do {
            let engine = try ChatEngine.engine()
            let viewController = try Messaging.instance.buildUI(
                engines: [engine],
                configs: [chatConfiguration, messageConfiguration]
            )
            return .success(viewController)
        } catch {
            return .failure(.chatProviderSDKError(error))
        }
    }
}

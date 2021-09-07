// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

enum CustomerSupportChatServiceError: Error {
    case unknown(Error)
}

protocol CustomerSupportChatServiceAPI {

    /// Initializes the ZenDesk SDK
    /// - Parameter key: API Key
    func initializeWithAcccountKey(_ key: String)

    /// Returns a `UIViewController` that is provided by the Customer
    /// Support SDK.
    /// - Parameter department: `CustomerSupportDepartment` - The department
    /// that the user would like to speak with.
    func buildMessagingScreenForDepartment(
        _ department: CustomerSupportDepartment
    ) -> AnyPublisher<UIViewController, CustomerSupportChatServiceError>
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum CustomerSupportChatServiceError: Error {
    case unknown(Error)
}

public protocol CustomerSupportChatServiceAPI {

    /// Initializes the Intercom SDK
    /// - Parameter key: API Key
    /// - Parameter appId: Intercom App ID
    func initializeWithAcccountKey(_ key: String, appId: String)

    /// Presents the Intercom Messenger
    func presentMessagingScreen()
}

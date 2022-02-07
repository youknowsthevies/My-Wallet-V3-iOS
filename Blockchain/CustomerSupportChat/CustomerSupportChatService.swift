// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit
import PlatformUIKit
import ToolKit

final class CustomerSupportChatService: CustomerSupportChatServiceAPI {

    private let emailSettingsService: EmailSettingsServiceAPI
    private let nabuUserService: NabuUserServiceAPI
    private var cancellables = Set<AnyCancellable>()
    private let client: CustomerSupportChatClientAPI

    init(
        emailSettingsService: EmailSettingsServiceAPI = resolve(),
        nabuUserService: NabuUserServiceAPI = resolve(),
        client: CustomerSupportChatClientAPI = resolve()
    ) {
        self.nabuUserService = nabuUserService
        self.emailSettingsService = emailSettingsService
        self.client = client
    }

    func initializeWithAcccountKey(
        _ key: String,
        appId: String
    ) {
        client.setupWithAccountKey(key, applicationId: appId)
    }

    func presentMessagingScreen() {
        let userId = nabuUserService
            .user
            .map(\.identifier)
            .mapError(CustomerSupportChatServiceError.unknown)

        let email = emailSettingsService
            .emailPublisher
            // Customer support can confirm that the email
            // is correct.
            .replaceError(with: "")
            .mapError(to: CustomerSupportChatServiceError.self)

        userId.zip(email)
            .map { userId, email in
                VisitorInformation(email: email, identifier: userId)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [client] visitorInfo in
                client
                    .presentMessagingScreenWithVisitorInfo(
                        visitorInfo
                    )
            })
            .store(in: &cancellables)
    }
}

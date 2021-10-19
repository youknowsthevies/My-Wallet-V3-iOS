// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit
import PlatformUIKit
import ToolKit

final class CustomerSupportChatService: CustomerSupportChatServiceAPI {

    private let emailSettingsService: EmailSettingsServiceAPI
    private let nabuUserService: NabuUserServiceAPI
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

    func initializeWithAcccountKey(_ key: String) {
        client.setupWithAccountKey(key)
    }

    func buildMessagingScreenForDepartment(
        _ department: CustomerSupportDepartment
    ) -> AnyPublisher<UIViewController, CustomerSupportChatServiceError> {
        Publishers
            .Zip(
                emailSettingsService
                    .emailPublisher
                    // Customer support can confirm that the email
                    // is correct.
                    .replaceError(with: ""),
                nabuUserService.user
                    .map(\.personalDetails)
                    .map(\.fullName)
            )
            .map { email, fullName in
                VisitorInformation(email: email, name: fullName)
            }
            .receive(on: DispatchQueue.main)
            .flatMap { [client] visitorInformation -> AnyPublisher<UIViewController, CustomerSupportChatServiceError> in
                let result = client
                    .buildMessagingScreenWithVisitorInfo(
                        visitorInformation,
                        department: department
                    )
                switch result {
                case .success(let controller):
                    return .just(controller)
                case .failure(let error):
                    return .failure(CustomerSupportChatServiceError.unknown(error))
                }
            }
            .eraseToAnyPublisher()
    }
}

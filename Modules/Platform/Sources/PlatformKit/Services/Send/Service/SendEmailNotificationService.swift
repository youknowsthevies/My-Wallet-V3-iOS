// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAuthenticationDomain
import Foundation
import NetworkKit

public protocol SendEmailNotificationServiceAPI {
    func postSendEmailNotificationTrigger(
        _ moneyValue: MoneyValue
    ) -> AnyPublisher<Void, Never>
}

public class SendEmailNotificationService: SendEmailNotificationServiceAPI {

    private let client: SendEmailNotificationClientAPI
    private let credentialsRepository: CredentialsRepositoryAPI

    init(
        client: SendEmailNotificationClientAPI = resolve(),
        credentialsRepository: CredentialsRepositoryAPI = resolve()
    ) {
        self.client = client
        self.credentialsRepository = credentialsRepository
    }

    public func postSendEmailNotificationTrigger(
        _ moneyValue: MoneyValue
    ) -> AnyPublisher<Void, Never> {
        credentialsRepository.credentialsPublisher
            .ignoreFailure()
            .map { guid, sharedKey in
                SendEmailNotificationClient.Payload(
                    guid: guid,
                    sharedKey: sharedKey,
                    currency: moneyValue.code,
                    amount: moneyValue.toDisplayString(includeSymbol: false)
                )
            }
            .flatMap { [client] payload in
                client.postSendEmailNotificationTrigger(payload)
            }
            .ignoreFailure()
            .eraseToAnyPublisher()
    }
}

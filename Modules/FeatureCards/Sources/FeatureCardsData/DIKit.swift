// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureCardsDomain

extension DependencyContainer {

    // MARK: - FeatureCardsData Module

    public static var featureCardsData = module {
        // MARK: - Clients - Cards

        factory { CardClient() as CardClientAPI }

        factory { EveryPayClient() as EveryPayClientAPI }

        factory { () -> CardListClientAPI in
            let client: CardClientAPI = DIKit.resolve()
            return client as CardListClientAPI
        }

        factory { () -> CardDeletionClientAPI in
            let client: CardClientAPI = DIKit.resolve()
            return client as CardDeletionClientAPI
        }

        factory { () -> CardDetailClientAPI in
            let client: CardClientAPI = DIKit.resolve()
            return client as CardDetailClientAPI
        }

        // MARK: - Repositories - Cards

        single { CardListRepository() as CardListRepositoryAPI }

        factory {
            ApplePayRepository(
                client: DIKit.resolve(),
                eligibleService: DIKit.resolve()
            ) as ApplePayRepositoryAPI
        }

        factory { CardAcquirersRepository() as CardAcquirersRepositoryAPI }
    }
}

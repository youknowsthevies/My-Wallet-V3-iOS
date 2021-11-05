// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureActivityDomain
import PlatformKit

extension DependencyContainer {

    // MARK: - FeatureInterestData Module

    public static var featureActivityDataKit = module {

        // MARK: - Data

        factory { APIClient() as InterestActivityItemEventClientAPI }

        // MARK: - Services

        factory { InterestActivityItemEventRepository() as InterestActivityItemEventRepositoryAPI }
    }
}

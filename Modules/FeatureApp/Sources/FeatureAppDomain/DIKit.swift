// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import FeatureAuthenticationDomain
import PlatformKit

extension DependencyContainer {

    // MARK: - FeatureAppDomain Module

    public static var featureAppDomain = module {

        single { () -> AnalyticsKit.TokenProvider in
            let tokenRepository: NabuTokenRepositoryAPI = DIKit.resolve()
            return { tokenRepository.sessionToken } as AnalyticsKit.TokenProvider
        }

        single { () -> FeatureAuthenticationDomain.NabuUserEmailProvider in
            let service: SettingsServiceAPI = DIKit.resolve()
            return { () -> AnyPublisher<String, Error> in
                service
                    .singleValuePublisher
                    .map(\.email)
                    .eraseError()
                    .eraseToAnyPublisher()
            } as FeatureAuthenticationDomain.NabuUserEmailProvider
        }
    }
}

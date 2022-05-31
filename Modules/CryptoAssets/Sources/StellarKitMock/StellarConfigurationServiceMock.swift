// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import StellarKit

final class StellarConfigurationServiceMock: StellarConfigurationServiceAPI {
    var configuration: AnyPublisher<StellarConfiguration, Never> = .just(
        StellarConfiguration.Stellar.test
    )
}

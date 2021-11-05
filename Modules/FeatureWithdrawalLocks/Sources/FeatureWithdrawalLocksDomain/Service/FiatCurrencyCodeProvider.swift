// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public protocol FiatCurrencyCodeProviderAPI {
    var defaultFiatCurrencyCode: AnyPublisher<String, Never> { get }
}

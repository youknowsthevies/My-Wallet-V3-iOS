// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

final class StellarServiceProvider {
    static let shared: StellarServiceProvider = .init(services: StellarServices())

    let services: StellarDependenciesAPI

    private init(services: StellarDependenciesAPI) {
        self.services = services
    }
}

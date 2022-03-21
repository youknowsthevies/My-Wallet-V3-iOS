// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct SearchedDomainResponse: Equatable, Decodable {
    struct DomainResponse: Equatable, Decodable {
        var node: String?
        var registryAddress: String?
        var blockchain: String?
        var freeToClaim: Bool?
        var id: Int?
        var networkId: Int?
        var name: String
    }

    struct AvailabilityResponse: Equatable, Decodable {
        var price: Int?
        var registered: Bool
        var protected: Bool
        var availableForFree: Bool
        var test: Bool?
    }
    var domain: DomainResponse
    var availability: AvailabilityResponse
}

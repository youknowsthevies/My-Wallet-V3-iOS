// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct SearchedDomainResponse: Equatable, Decodable {

    private enum CodingKeys: String, CodingKey {
        case domain
        case availability
    }

    var domain: DomainResponse
    var availability: AvailabilityResponse
}

struct DomainResponse: Equatable, Decodable {

    private enum CodingKeys: String, CodingKey {
        case node
        case registryAddress
        case blockchain
        case freeToClaim
        case id
        case networkId
        case name
    }

    var node: String?
    var registryAddress: String?
    var blockchain: String?
    var freeToClaim: Bool?
    var id: Int?
    var networkId: Int?
    var name: String
}

struct AvailabilityResponse: Equatable, Decodable {

    private enum CodingKeys: String, CodingKey {
        case price
        case registered
        case protected
        case availableForFree
        case test
    }

    var price: Int?
    var registered: Bool
    var protected: Bool
    var availableForFree: Bool
    var test: Bool?
}

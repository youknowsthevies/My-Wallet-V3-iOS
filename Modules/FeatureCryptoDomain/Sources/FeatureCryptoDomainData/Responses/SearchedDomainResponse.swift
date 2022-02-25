// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct SearchedDomainResponse: Codable {

    private enum CodingKeys: String, CodingKey {
        case domain
        case availability
    }

    var domain: DomainResponse
    var availability: AvailabilityResponse

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        domain = try container.decode(DomainResponse.self, forKey: .domain)
        availability = try container.decode(AvailabilityResponse.self, forKey: .availability)
    }
}

struct DomainResponse: Decodable {

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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        node = try container.decodeIfPresent(String.self, forKey: .node)
        registryAddress = try container.decodeIfPresent(String.self, forKey: .registryAddress)
        blockchain = try container.decodeIfPresent(String.self, forKey: .blockchain)
        freeToClaim = try container.decodeIfPresent(Bool.self, forKey: .freeToClaim)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        networkId = try container.decodeIfPresent(Int.self, forKey: .networkId)
        name = try container.decode(String.self, forKey: .name)
    }
}

struct AvailabilityResponse: Decodable {

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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        price = try container.decodeIfPresent(Int.self, forKey: .price)
        registered = try container.decode(Bool.self, forKey: .registered)
        protected = try container.decode(Bool.self, forKey: .protected)
        availableForFree = try container.decode(Bool.self, forKey: .availableForFree)
        test = try container.decodeIfPresent(Bool.self, forKey: .test)
    }
}

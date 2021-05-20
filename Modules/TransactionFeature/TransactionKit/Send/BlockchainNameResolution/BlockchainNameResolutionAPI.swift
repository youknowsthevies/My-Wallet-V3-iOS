//
//  BlockchainNameResolutionAPI.swift
//  ActivityKit
//
//  Created by Paulo on 27/04/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Combine
import DIKit
import NetworkKit

struct DomainResolutionRequest: Encodable {
    let currency: String
    let name: String
}

struct DomainResolutionResponse: Decodable {
    let currency: String
    let address: String
}

protocol BlockchainNameResolutionAPI {
    func resolve(domainName: String, currency: String) -> AnyPublisher<DomainResolutionResponse, NetworkError>
}

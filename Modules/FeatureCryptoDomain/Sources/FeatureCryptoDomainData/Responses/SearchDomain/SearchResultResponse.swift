// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureCryptoDomainDomain
import Foundation

public struct FreeSearchResultResponse: Equatable, Decodable {
    var suggestions: [SuggestionResponse]
}

public struct SearchResultResponse: Equatable, Decodable {
    var suggestions: [SuggestionResponse]
    var searchedDomain: SearchedDomainResponse
}

extension SearchDomainResult {

    init(from response: SuggestionResponse) {
        self.init(
            domainName: response.name,
            domainType: .free,
            domainAvailability: .availableForFree
        )
    }

    init(from response: SearchedDomainResponse) {
        let isAvailable = !response.availability.registered && !response.availability.protected
        let isFree = response.availability.availableForFree
        let price = String(response.availability.price ?? 0)
        self.init(
            domainName: response.domain.name,
            domainType: isFree ? .free : .premium,
            domainAvailability: !isAvailable ? .unavailable : isFree ? .availableForFree : .availableForPremiumSale(price: price)
        )
    }
}

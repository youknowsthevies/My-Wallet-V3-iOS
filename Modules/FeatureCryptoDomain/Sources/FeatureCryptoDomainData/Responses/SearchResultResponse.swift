// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import FeatureCryptoDomainDomain

struct SearchResultResponse: Decodable {

    private enum CodingKeys: String, CodingKey {
        case suggestions
        case searchedDomain
    }

    var suggestions: [SuggestionResponse]
    var searchedDomain: SearchedDomainResponse

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        suggestions = try container.decode([SuggestionResponse].self, forKey: .suggestions)
        searchedDomain = try container.decode(SearchedDomainResponse.self, forKey: .searchedDomain)
    }
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

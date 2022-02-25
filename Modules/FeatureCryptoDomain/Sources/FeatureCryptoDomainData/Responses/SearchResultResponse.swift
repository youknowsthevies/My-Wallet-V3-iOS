// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct SearchResultResponse: Decodable {

    private enum CodingKeys: String, CodingKey {
        case suggestions
        case searchedDomain
    }

    var suggestions: [SuggestionResponse]?
    var searchedDomain: SearchedDomainResponse?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        suggestions = try container.decodeIfPresent([SuggestionResponse].self, forKey: .suggestions)
        searchedDomain = try container.decodeIfPresent(SearchedDomainResponse.self, forKey: .searchedDomain)
    }
}

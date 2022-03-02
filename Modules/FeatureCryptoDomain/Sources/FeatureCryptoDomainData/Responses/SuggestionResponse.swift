// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct SuggestionResponse: Equatable, Decodable {

    private enum CodingKeys: String, CodingKey {
        case price
        case name
    }

    var price: Int?
    var name: String
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct SuggestionResponse: Decodable {

    private enum CodingKeys: String, CodingKey {
        case price
        case name
    }

    var price: Int?
    var name: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        price = try container.decodeIfPresent(Int.self, forKey: .price)
        name = try container.decode(String.self, forKey: .name)
    }
}

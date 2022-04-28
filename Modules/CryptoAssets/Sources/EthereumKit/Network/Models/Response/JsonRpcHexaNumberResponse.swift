// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Foundation

/// A Json RPC response with a hexadecimal number as 'result'.
/// The number will be converted to a `BigInt`.
public struct JsonRpcHexaNumberResponse: Decodable {

    // MARK: Types

    private enum CodingKeys: CodingKey {
        case result
    }

    // MARK: Properties

    public let result: BigInt

    // MARK: Init

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let value = try container.decode(String.self, forKey: .result)
        guard let result = BigInt(value.withoutHex, radix: 16) else {
            throw DecodingError.dataCorruptedError(
                forKey: .result,
                in: container,
                debugDescription: "'result' is not a hexadecimal BigInt number."
            )
        }
        self.result = result
    }
}

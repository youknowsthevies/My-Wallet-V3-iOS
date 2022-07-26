// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct BchDustResponse: Decodable {
    let tx_hash: String
    let tx_hash_big_endian: String
    let tx_index: Int
    let tx_output_n: Int
    let script: String
    let value: Int
    let value_hex: String
    let confirmations: Int
    let output_script: String
    let lock_secret: String
}

//
//  CoinifyAccountRepositoryAPI.swift
//  PlatformKit
//
//  Created by Paulo on 10/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol CoinifyAccountRepositoryAPI {
    func save(accountID: Int, token: String) -> Completable
    func coinifyMetadata() -> Maybe<CoinifyMetadata>
    func hasCoinifyAccount() -> Bool
}

public struct CoinifyMetadata: Decodable {
    public let traderIdentifier: Int
    public let offlineToken: String

    enum CodingKeys: String, CodingKey {
        case user
        case token = "offline_token"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        traderIdentifier = try values.decode(Int.self, forKey: .user)
        offlineToken = try values.decode(String.self, forKey: .token)
    }

    public init(identifier: Int, token: String) {
        self.traderIdentifier = identifier
        self.offlineToken = token
    }
}

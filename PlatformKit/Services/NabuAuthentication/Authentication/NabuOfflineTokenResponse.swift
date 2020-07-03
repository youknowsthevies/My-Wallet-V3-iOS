//
//  NabuOfflineTokenResponse.swift
//  PlatformKit
//
//  Created by Daniel on 26/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public struct NabuOfflineTokenResponse: Decodable, Equatable {
    public let userId: String
    public let token: String
    
    public init(userId: String, token: String) {
        self.userId = userId
        self.token = token
    }
}

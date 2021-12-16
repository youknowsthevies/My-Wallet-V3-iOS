// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct MetadataPayload: Equatable {

    let version: Int
    let payload: String
    let signature: String
    let prevMagicHash: String?
    let typeId: Int
    let createdAt: Int
    let updatedAt: Int
    let address: String

    public init(
        version: Int,
        payload: String,
        signature: String,
        prevMagicHash: String?,
        typeId: Int,
        createdAt: Int,
        updatedAt: Int,
        address: String
    ) {
        self.version = version
        self.payload = payload
        self.signature = signature
        self.prevMagicHash = prevMagicHash
        self.typeId = typeId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.address = address
    }
}

public struct MetadataBody: Equatable {

    public let version: Int
    public let payload: String
    public let signature: String
    public let prevMagicHash: String?
    public let typeId: Int

    public init(
        version: Int,
        payload: String,
        signature: String,
        prevMagicHash: String?,
        typeId: Int
    ) {
        self.version = version
        self.payload = payload
        self.signature = signature
        self.prevMagicHash = prevMagicHash
        self.typeId = typeId
    }
}

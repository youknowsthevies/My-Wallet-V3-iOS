// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MetadataKit
import ToolKit

public struct UserCredentials: Equatable {
    public let userId: String
    public let lifetimeToken: String

    public init(userId: String, lifetimeToken: String) {
        self.userId = userId
        self.lifetimeToken = lifetimeToken
    }

    static func from(entry: UserCredentialsEntryPayload) -> Self {
        UserCredentials(
            userId: entry.userId,
            lifetimeToken: entry.lifetimeToken
        )
    }
}

public protocol UserCredentialsFetcherAPI {
    /// Fetches the `UserCredentials` from Wallet metadata
    func fetchUserCredentials() -> AnyPublisher<UserCredentials, WalletAssetFetchError>

    /// Stores the passed UserCredentials to metadata
    /// - Parameter credentials: A `UserCredentials` value
    func store(credentials: UserCredentials) -> AnyPublisher<EmptyValue, WalletAssetFetchError>
}

final class UserCredentialsFetcher: UserCredentialsFetcherAPI {

    private let metadataEntryService: WalletMetadataEntryServiceAPI

    init(metadataEntryService: WalletMetadataEntryServiceAPI) {
        self.metadataEntryService = metadataEntryService
    }

    func fetchUserCredentials() -> AnyPublisher<UserCredentials, WalletAssetFetchError> {
        metadataEntryService.fetchEntry(type: UserCredentialsEntryPayload.self)
            .map(UserCredentials.from(entry:))
            .eraseToAnyPublisher()
    }

    func store(credentials: UserCredentials) -> AnyPublisher<EmptyValue, WalletAssetFetchError> {
        unimplemented()
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NabuNetworkError
import ToolKit

public enum AssetProviderServiceError: Error, Equatable {
    case failedToFetchEthereumWallet
    case network(NabuNetworkError)
}

public protocol AssetProviderServiceAPI {
    func fetchAssetsFromEthereumAddress()
        -> AnyPublisher<[Asset], AssetProviderServiceError>
}

public final class AsssetProviderService: AssetProviderServiceAPI {

    private let repository: AssetProviderRepositoryAPI
    private let ethereumWalletAddressPublisher: AnyPublisher<String, Error>

    public init(
        repository: AssetProviderRepositoryAPI,
        ethereumWalletAddressPublisher: AnyPublisher<String, Error>
    ) {
        self.repository = repository
        self.ethereumWalletAddressPublisher = ethereumWalletAddressPublisher
    }

    public func fetchAssetsFromEthereumAddress()
        -> AnyPublisher<[Asset], AssetProviderServiceError>
    {
        ethereumWalletAddressPublisher
            .replaceError(
                with: AssetProviderServiceError.failedToFetchEthereumWallet
            )
            .flatMap { [repository] address in
                repository
                    .fetchAssetsFromEthereumAddress(address)
                    .mapError(AssetProviderServiceError.network)
            }
            .eraseToAnyPublisher()
    }
}

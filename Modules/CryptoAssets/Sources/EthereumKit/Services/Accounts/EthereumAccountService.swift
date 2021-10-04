// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit
import ToolKit

public protocol EthereumAccountServiceAPI {

    /// Checks if a given ethereum address is associated with an ethereum smart contract.
    ///
    /// - Parameter address: An ethereum address.
    ///
    /// - Returns: A publisher that emits a `Bool` on success, or a `NetworkError` on failure.
    func isContract(address: String) -> AnyPublisher<Bool, NetworkError>
}

final class EthereumAccountService: EthereumAccountServiceAPI {

    // MARK: - Private Types

    private typealias Tag = DependencyContainer.Tags.EthereumAccountService

    // MARK: - Private Properties

    /// The ethereum account client.
    private let accountClient: EthereumAccountClientAPI

    /// The dictionary of boolean truth values of ethereum addresses being associated with ethereum smart contracts, indexed by their respective address.
    private let isContractAddressCache: Atomic<[String: Bool]>

    // MARK: - Setup

    /// Creates an ethereum account service.
    ///
    /// - Parameters:
    ///   - accountClient:          An ethereum account client.
    ///   - isContractAddressCache: An atomic dictionary.
    init(
        accountClient: EthereumAccountClientAPI = resolve(),
        isContractAddressCache: Atomic<[String: Bool]> = resolve(tag: Tag.isContractAddressCache)
    ) {
        self.accountClient = accountClient
        self.isContractAddressCache = isContractAddressCache
    }

    // MARK: Internal Methods

    func isContract(address: String) -> AnyPublisher<Bool, NetworkError> {
        guard let isContractAddress = isContractAddressCache.value[address] else {
            return accountClient
                .isContract(address: address)
                .map(\.contract)
                .handleEvents(receiveOutput: { [isContractAddressCache] isContract in
                    isContractAddressCache.mutate { $0[address] = isContract }
                })
                .eraseToAnyPublisher()
        }

        return .just(isContractAddress)
    }
}

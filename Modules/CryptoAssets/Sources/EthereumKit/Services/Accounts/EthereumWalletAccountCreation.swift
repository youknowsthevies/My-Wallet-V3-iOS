// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MetadataKit
import MoneyKit
import WalletCore
import WalletPayloadKit

/// First fetches the entry and then it checks if it needs to create a new entry and saves that entry
func fetchOrCreateEthereumNatively(
    metadataService: WalletMetadataEntryServiceAPI,
    hdWalletProvider: @escaping WalletCoreHDWalletProvider,
    label: String?
) -> AnyPublisher<EthereumEntryPayload, WalletAssetFetchError> {
    metadataService.fetchEntry(type: EthereumEntryPayload.self)
        .flatMap { entry -> AnyPublisher<(entry: EthereumEntryPayload, needsSaving: Bool), WalletAssetFetchError> in
            if needsReplenish(entry: entry) {
                return replenishAccount(
                    entry: entry,
                    hdWalletProvider: hdWalletProvider,
                    label: label
                )
                .map { entry in (entry, true) }
                .eraseToAnyPublisher()
            }
            return .just((entry, false))
        }
        .catch { error -> AnyPublisher<(entry: EthereumEntryPayload, needsSaving: Bool), WalletAssetFetchError> in
            guard case .fetchFailed(.loadMetadataError(.notYetCreated)) = error else {
                return .failure(error)
            }
            return createEthereumEntry(
                hdWalletProvider: hdWalletProvider,
                label: label
            )
            .map { entry in (entry, true) }
            .eraseToAnyPublisher()
        }
        .flatMap { entry, needsSaving -> AnyPublisher<EthereumEntryPayload, WalletAssetFetchError> in
            guard needsSaving else {
                return .just(entry)
            }
            return metadataService.save(node: entry)
                .map { _ in entry }
                .mapError { _ in WalletAssetFetchError.notInitialized }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
}

// MARK: - Private methods

private func needsReplenish(
    entry: EthereumEntryPayload
) -> Bool {
    guard let ethereum = entry.ethereum else {
        return true
    }
    let noAccountsFound = ethereum.accounts.isEmpty
    let accountIsCorrect = ethereum.accounts.first?.correct ?? false
    return noAccountsFound || !accountIsCorrect
}

/// Replenishes an `EthereumEntryPayload` in case it missing important information
private func replenishAccount(
    entry: EthereumEntryPayload,
    hdWalletProvider: @escaping WalletCoreHDWalletProvider,
    label: String?
) -> AnyPublisher<EthereumEntryPayload, WalletAssetFetchError> {
    guard let ethereum = entry.ethereum else {
        // if the top level ethereum account is missing recreate one
        return createEthereumEntry(
            hdWalletProvider: hdWalletProvider,
            label: label
        )
    }
    let accountIsCorrect = ethereum.accounts.first?.correct ?? false
    guard ethereum.accounts.isEmpty || !accountIsCorrect else {
        return .just(entry)
    }
    // if we are missing ETH accounts the update the entry
    return hdWalletProvider()
        .mapError { _ in WalletAssetFetchError.notInitialized }
        .map { hdWallet -> EthereumEntryPayload.Ethereum.Account in
            let key = generatePrivateKey(hdWallet: hdWallet, accountIndex: 0)
            let address = generateEthereumAddress(privateKey: key)
            return provideEthAccount(address: address, label: label)
        }
        .map { account -> EthereumEntryPayload in
            let accounts = ethereum.accounts + [account]
            let ethereum = EthereumEntryPayload.Ethereum(
                accounts: accounts,
                defaultAccountIndex: ethereum.defaultAccountIndex,
                erc20: ethereum.erc20,
                hasSeen: ethereum.hasSeen,
                lastTxTimestamp: ethereum.lastTxTimestamp,
                transactionNotes: ethereum.transactionNotes
            )
            return EthereumEntryPayload(ethereum: ethereum)
        }
        .eraseToAnyPublisher()
}

private func createEthereumEntry(
    hdWalletProvider: WalletCoreHDWalletProvider,
    label: String?
) -> AnyPublisher<EthereumEntryPayload, WalletAssetFetchError> {
    hdWalletProvider()
        .mapError { _ in WalletAssetFetchError.notInitialized }
        .map { hdWallet -> EthereumEntryPayload in
            let key = generatePrivateKey(hdWallet: hdWallet, accountIndex: 0)
            let address = generateEthereumAddress(privateKey: key)
            let nodeToBeSaved = provideEthEntryPayload(address: address, label: label)
            return nodeToBeSaved
        }
        .eraseToAnyPublisher()
}

private func provideEthEntryPayload(
    address: String,
    label: String?
) -> EthereumEntryPayload {
    let account = provideEthAccount(
        address: address,
        label: label
    )
    let eth = EthereumEntryPayload.Ethereum(
        accounts: [account],
        defaultAccountIndex: 0,
        erc20: nil,
        hasSeen: false,
        lastTxTimestamp: nil,
        transactionNotes: [:]
    )
    return EthereumEntryPayload(ethereum: eth)
}

private func provideEthAccount(
    address: String,
    label: String?
) -> EthereumEntryPayload.Ethereum.Account {
    EthereumEntryPayload.Ethereum.Account(
        address: address,
        archived: false,
        correct: true,
        label: label ?? CryptoCurrency.ethereum.defaultWalletName
    )
}

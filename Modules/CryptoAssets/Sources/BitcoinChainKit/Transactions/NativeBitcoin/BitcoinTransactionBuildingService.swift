// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import ToolKit

public enum BitcoinTransactionBuildingServiceError: Error {}

public protocol BitcoinTransactionBuildingServiceAPI {

    /// To create a bitcoin payment candidate for transaction
    /// - Parameters:
    ///   - source: the key pairs of the source crypto account
    ///   - destinationAddress: the destination wallet address
    ///   - amount: the amonut to be sent
    ///   - feePerByte: the fee per byte used in the transaction (regular or priority)
    /// - Returns:
    ///   - An `AnyPublisher` that returns an transaction candidate or error
    func buildCandidate<Token: BitcoinChainToken>(
        source: [WalletKeyPair],
        destinationAddress: String,
        amount: CryptoValue,
        feePerByte: CryptoValue
    ) -> AnyPublisher<NativeBitcoinChainTransactionCandidate<Token>, BitcoinTransactionBuildingServiceError>

    /// To create a decoy candidate for getting sweepAmount and sweepFee
    /// Note that the candidate is not intended to be used for signing
    /// - Parameters:
    ///   - source: the key pairs of the source crypto account
    ///   - feePerByte: the fee per byte used in the transaction (regular or priority)
    /// - Returns:
    ///   - An `AnyPublisher` that returns a sweep candidate or error
    func buildSweepCandidate<Token: BitcoinChainToken>(
        source: [WalletKeyPair],
        feePerByte: CryptoValue
    ) -> AnyPublisher<NativeBitcoinChainSweepCandidate<Token>, BitcoinTransactionBuildingServiceError>
}

final class BitcoinTransactionBuildingService: BitcoinTransactionBuildingServiceAPI {

    // MARK: - Properties

    private let unspentOutputRepository: UnspentOutputRepositoryAPI
    private let coinSelection: CoinSelector

    // MARK: - Setup

    init(
        unspentOutputRepository: UnspentOutputRepositoryAPI,
        coinSelection: CoinSelector
    ) {
        self.unspentOutputRepository = unspentOutputRepository
        self.coinSelection = coinSelection
    }

    // MARK: - API

    func buildCandidate<Token: BitcoinChainToken>(
        source: [WalletKeyPair],
        destinationAddress: String,
        amount: CryptoValue,
        feePerByte: CryptoValue
    ) -> AnyPublisher<NativeBitcoinChainTransactionCandidate<Token>, BitcoinTransactionBuildingServiceError> {
        /* TODO: Implementation Plan:
          1. Get UTXOs from UnspentOutputsRepository using the xPubs array
          2. Calculate fee, change, UTXOs etc using CoinSelection given the UTXOs from (1)
          3. Build the transaction candidate

         Discussion Notes:
          - the source xPubs should be in array or set
          - use crypto value for candidate amount and fee
          - remove the need of HD wallet index
          - no need to calculate sweep fee and amount every time a normal transaction is created
         */
        unimplemented()
    }

    func buildSweepCandidate<Token>(
        source: [WalletKeyPair],
        feePerByte: CryptoValue
    ) -> AnyPublisher<NativeBitcoinChainSweepCandidate<Token>, BitcoinTransactionBuildingServiceError> where Token: BitcoinChainToken {
        /* TODO: Implementation Plan:
         1. Get UTXOs from UnspentOutputsRepository using the xPubs array
         2. Use CoinSelection, sweep variation
         3. Build the sweep candidate
         */
        unimplemented()
    }
}

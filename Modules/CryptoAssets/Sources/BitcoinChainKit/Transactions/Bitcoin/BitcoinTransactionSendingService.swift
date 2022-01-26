// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import PlatformKit
import ToolKit

public enum BitcoinTransactionBuildingServiceError: Error {}

public protocol BitcoinTransactionBuildingServiceAPI {

    func buildProposal<Token: BitcoinChainToken>(
        with destination: BitcoinChainReceiveAddress<Token>,
        amount: MoneyValue,
        fees: MoneyValue,
        source: CryptoAccount
    ) -> AnyPublisher<BitcoinChainTransactionProposal<Token>, BitcoinTransactionBuildingServiceError>

    func buildCandidate<Token: BitcoinChainToken>(
        with proposal: BitcoinChainTransactionProposal<Token>
    ) -> AnyPublisher<BitcoinChainTransactionCandidate<Token>, BitcoinTransactionBuildingServiceError>
}

final class BitcoinTransactionBuildingService: BitcoinTransactionBuildingServiceAPI {

    func buildProposal<Token: BitcoinChainToken>(
        with destination: BitcoinChainReceiveAddress<Token>,
        amount: MoneyValue,
        fees: MoneyValue,
        source: CryptoAccount
    ) -> AnyPublisher<BitcoinChainTransactionProposal<Token>, BitcoinTransactionBuildingServiceError> {
        unimplemented()
    }

    func buildCandidate<Token: BitcoinChainToken>(
        with proposal: BitcoinChainTransactionProposal<Token>
    ) -> AnyPublisher<BitcoinChainTransactionCandidate<Token>, BitcoinTransactionBuildingServiceError> {
        unimplemented()
    }
}

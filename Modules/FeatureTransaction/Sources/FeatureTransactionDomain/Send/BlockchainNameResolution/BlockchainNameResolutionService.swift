//
//  BlockchainNameResolutionService.swift
//  FeatureActivityDomain
//
//  Created by Paulo on 27/04/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Combine
import DIKit
import MoneyKit
import PlatformKit

public protocol BlockchainNameResolutionServiceAPI {

    func validate(
        domainName: String,
        currency: CryptoCurrency
    ) -> AnyPublisher<ReceiveAddress?, Never>
}

final class BlockchainNameResolutionService: BlockchainNameResolutionServiceAPI {

    private let repository: BlockchainNameResolutionRepositoryAPI
    private let factory: ExternalAssetAddressServiceAPI

    init(
        repository: BlockchainNameResolutionRepositoryAPI = resolve(),
        factory: ExternalAssetAddressServiceAPI = resolve()
    ) {
        self.repository = repository
        self.factory = factory
    }

    func validate(
        domainName: String,
        currency: CryptoCurrency
    ) -> AnyPublisher<ReceiveAddress?, Never> {
        guard preValidate(domainName: domainName) else {
            return .just(nil)
        }
        return repository
            .resolve(domainName: domainName, currency: currency.code.lowercased())
            .eraseError()
            .flatMap { [factory] response -> AnyPublisher<ReceiveAddress?, Error> in
                factory
                    .makeExternalAssetAddress(
                        asset: currency,
                        address: response.address,
                        label: Self.label(address: response.address, domain: domainName),
                        onTxCompleted: { _ in .empty() }
                    )
                    .map { $0 as ReceiveAddress }
                    .publisher
                    .eraseToAnyPublisher()
                    .eraseError()
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

    private static func label(address: String, domain: String) -> String {
        "\(domain) (\(address.prefix(4))...\(address.suffix(4))"
    }

    private func preValidate(domainName: String) -> Bool {
        // Separated by '.' (period)
        let components = domainName.components(separatedBy: ".")
        // Must have more than one component
        guard components.count > 1 else {
            return false
        }
        // No component may be empty
        guard !components.contains(where: \.isEmpty) else {
            return false
        }
        // Pre validation passes
        return true
    }
}

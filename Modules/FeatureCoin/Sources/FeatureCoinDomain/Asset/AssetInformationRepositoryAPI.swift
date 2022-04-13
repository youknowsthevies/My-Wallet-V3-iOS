// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MoneyKit
import NetworkError

public protocol AssetInformationRepositoryAPI {
    func fetchInfo(_ currencyCode: String) -> AnyPublisher<AssetInformation, NetworkError>
}

public class AssetInformationService {

    let currency: CryptoCurrency
    let repository: AssetInformationRepositoryAPI

    public init(currency: CryptoCurrency, repository: AssetInformationRepositoryAPI) {
        self.currency = currency
        self.repository = repository
    }

    public func fetch() -> AnyPublisher<AssetInformation, NetworkError> {
        repository.fetchInfo(currency.code)
    }
}

extension AssetInformationService {

    public static var preview: AssetInformationService {
        .init(currency: .bitcoin, repository: PreviewAssetInformationRepository())
    }
}

private struct PreviewAssetInformationRepository: AssetInformationRepositoryAPI {

    func fetchInfo(_ currencyCode: String) -> AnyPublisher<AssetInformation, NetworkError> {
        Just(.preview).setFailureType(to: NetworkError.self).eraseToAnyPublisher()
    }
}

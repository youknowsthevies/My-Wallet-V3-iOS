// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import MoneyKit

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

// MARK: - Preview Helper

extension AssetInformationService {

    public static var preview: AssetInformationService {
        .init(currency: .bitcoin, repository: PreviewAssetInformationRepository(.just(.preview)))
    }

    public static var previewEmpty: AssetInformationService {
        .init(currency: .bitcoin, repository: PreviewAssetInformationRepository())
    }
}

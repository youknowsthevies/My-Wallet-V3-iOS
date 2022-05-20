// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MoneyKit
import NetworkError
import ToolKit

public protocol AssetInformationRepositoryAPI {

    func fetchInfo(_ currencyCode: String) -> AnyPublisher<AssetInformation, NetworkError>
}

// MARK: - Preview Helper

struct PreviewAssetInformationRepository: AssetInformationRepositoryAPI {

    private let assetInformation: AnyPublisher<AssetInformation, NetworkError>

    init(_ assetInformation: AnyPublisher<AssetInformation, NetworkError> = .empty()) {
        self.assetInformation = assetInformation
    }

    func fetchInfo(_ currencyCode: String) -> AnyPublisher<AssetInformation, NetworkError> {
        assetInformation
    }
}

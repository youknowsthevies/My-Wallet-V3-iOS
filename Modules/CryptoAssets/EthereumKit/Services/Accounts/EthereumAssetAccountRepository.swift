// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxRelay
import RxSwift

open class EthereumAssetAccountRepository: AssetAccountRepositoryAPI {

    public typealias Details = EthereumAssetAccountDetails

    public var assetAccountDetails: Single<Details> {
        currentAssetAccountDetails(fromCache: true)
    }

    private let service: EthereumAssetAccountDetailsService

    init(service: EthereumAssetAccountDetailsService = resolve()) {
        self.service = service
    }

    public func currentAssetAccountDetails(fromCache: Bool) -> Single<Details> {
        let accountId = "0"
        return fetchAssetAccountDetails(for: accountId)
    }

    // MARK: Private Functions

    fileprivate func fetchAssetAccountDetails(for accountID: String) -> Single<Details> {
        service.accountDetails(for: accountID)
    }
}

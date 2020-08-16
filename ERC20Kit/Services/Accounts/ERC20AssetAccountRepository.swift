//
//  ERC20AssetAccountRepository.swift
//  ERC20Kit
//
//  Created by Jack on 15/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxCocoa
import RxSwift

public class ERC20AssetAccountRepository<Token: ERC20Token>: AssetAccountRepositoryAPI {
    public typealias Details = ERC20AssetAccountDetails
    
    public var assetAccountDetails: Single<Details> {
        currentAssetAccountDetails(fromCache: false)
    }

    private let service: AnyAssetAccountDetailsAPI<Details>
    
    public init(service: AnyAssetAccountDetailsAPI<Details> = resolve(tag: Token.assetType)) {
        self.service = service
    }
    
    public func currentAssetAccountDetails(fromCache: Bool) -> Single<Details> {
        fetchAssetAccountDetails(for: "0")
    }

    // MARK: Private Functions
    
    private func fetchAssetAccountDetails(for accountID: String) -> Single<Details> {
        service.accountDetails(for: accountID)
    }
}

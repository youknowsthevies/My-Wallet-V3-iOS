//
//  SingleAccountBadgeFactory.swift
//  PlatformUIKit
//
//  Created by Paulo on 16/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformKit
import RxSwift

final class SingleAccountBadgeFactory {
    func badge(account: SingleAccount, action: AssetAction) -> Single<[BadgeAssetPresenting]> {
        switch action {
        case .swap:
            return swapBadges(account: account)
        default:
            return .just([])
        }
    }

    private func swapBadges(account: BlockchainAccount) -> Single<[BadgeAssetPresenting]> {
        if account is CryptoTradingAccount {
            let lowFeeBadge = DefaultBadgeAssetPresenter.makeLowFeesBadge()
            return .just([lowFeeBadge])
        } else {
            return .just([])
        }
    }
}

fileprivate extension DefaultBadgeAssetPresenter {
    private typealias LocalizedString = LocalizationConstants.Account

    static func makeLowFeesBadge() -> DefaultBadgeAssetPresenter {
        let item = BadgeAsset.Value.Interaction.BadgeItem(type: .verified, description: LocalizedString.lowFees)
        let interactor = DefaultBadgeAssetInteractor(initialState: .loaded(next: item))
        return DefaultBadgeAssetPresenter(interactor: interactor)
    }
}

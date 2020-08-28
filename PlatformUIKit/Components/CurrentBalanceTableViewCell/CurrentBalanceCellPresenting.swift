//
//  CurrentBalanceCellPresenting.swift
//  PlatformUIKit
//
//  Created by Paulo on 17/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxCocoa
import RxSwift

public protocol CurrentBalanceCellPresenting {
    var iconImageViewContent: Driver<ImageViewContent> { get }

    var badgeImageViewModel: Driver<BadgeImageViewModel> { get }

    /// Returns the description of the balance
    var title: Driver<String> { get }

    /// Returns the description of the balance
    var description: Driver<String> { get }

    var separatorVisibility: Driver<Visibility> { get }

    var titleAccessibilitySuffix: String { get }

    var descriptionAccessibilitySuffix: String { get }

    var assetBalanceViewPresenter: AssetBalanceViewPresenter { get }
}

//
//  BadgeCellPresenting.swift
//  PlatformUIKit
//
//  Created by AlexM on 12/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit
import RxCocoa

/// This is used on `BadgeTableViewCell`. There are many
/// types of `BadgeTableViewCell` (e.g. PIT connection status, KYC status, mobile
/// verification status, etc). Each of these cells need their own implementation of
/// `LabelContentPresenting` and `BadgeAssetPresenting`
public protocol BadgeCellPresenting: AsyncPresenting {
    var accessibility: Accessibility { get }
    var labelContentPresenting: LabelContentPresenting { get }
    var badgeAssetPresenting: BadgeAssetPresenting { get }
}

extension BadgeCellPresenting {
    var accessibility: Accessibility {
        .none
    }
}

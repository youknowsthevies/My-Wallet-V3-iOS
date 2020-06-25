//
//  CustodialFeatureFetching.swift
//  PlatformKit
//
//  Created by Paulo on 18/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// CustodialFeatureFetching wrapps a [FeatureFetching](x-source-tag://FeatureFetching) call inside a KYCTier status check.
public protocol CustodialFeatureFetching {
    /// - Parameter key: The `AppFeature` case to be evaluated.
    /// - Returns: If the KYC tier status check fails emits `false`, else emits `FeatureFetching.fetchBool(for: key)`
    func featureEnabled(for key: AppFeature) -> Single<Bool>
}

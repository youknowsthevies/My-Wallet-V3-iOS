// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol AssetPriceViewInteracting: class {
    var state: Observable<DashboardAsset.State.AssetPrice.Interaction> { get }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxSwift

public protocol AssetPriceViewInteracting: AnyObject {
    var state: Observable<DashboardAsset.State.AssetPrice.Interaction> { get }

    func refresh()
}

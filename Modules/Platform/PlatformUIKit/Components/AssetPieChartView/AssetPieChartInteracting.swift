// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol AssetPieChartInteracting: class {
    var state: Observable<AssetPieChart.State.Interaction> { get }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

enum TodayExtensionCellInteractor {
    case assetPrice(AssetPriceCellInteractor)
    case portfolio(PortfolioCellInteractor)

    var cellType: TodayExtensionSectionType.CellType {
        switch self {
        case .assetPrice(let interactor):
            return .price(.init(interactor: interactor))
        case .portfolio(let interactor):
            return .portfolio(.init(interactor: interactor))
        }
    }
}

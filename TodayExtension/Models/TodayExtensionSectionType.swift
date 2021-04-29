// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxDataSources

enum TodayExtensionSectionType: String, Equatable {
    case balance
    case assetPrices
    
    enum CellType: Equatable, IdentifiableType {
        
        typealias Identity = String
        
        var identity: String {
            switch self {
            case .price(let presenter):
                return presenter.currency.code
            case .portfolio:
                return "portfolio"
            }
        }
        
        static func == (lhs: TodayExtensionSectionType.CellType, rhs: TodayExtensionSectionType.CellType) -> Bool {
            switch (lhs, rhs) {
            case (.price(let left), .price(let right)):
                return left.currency.code == right.currency.code
            case (.portfolio, .portfolio):
                return true
            default:
                return false
            }
        }
        
        case price(AssetPriceCellPresenter)
        case portfolio(PortfolioCellPresenter)
    }
}

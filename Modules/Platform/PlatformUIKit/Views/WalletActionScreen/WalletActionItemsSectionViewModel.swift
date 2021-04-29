// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxDataSources
import ToolKit

public struct WalletActionItemsSectionViewModel {
    public var items: [WalletActionCellType]
    
    public var identity: AnyHashable {
        // There's only ever one `WalletActionItemsSectionViewModel` section
        // so it must be a static string for an identifier.
        "WalletActionItemsSectionViewModel"
    }
}

extension WalletActionItemsSectionViewModel {
    static let empty: WalletActionItemsSectionViewModel = .init(items: [])
}

extension WalletActionItemsSectionViewModel: AnimatableSectionModelType {
    public typealias Item = WalletActionCellType
    
    public init(original: WalletActionItemsSectionViewModel, items: [WalletActionCellType]) {
        self = original
        self.items = items
    }
}


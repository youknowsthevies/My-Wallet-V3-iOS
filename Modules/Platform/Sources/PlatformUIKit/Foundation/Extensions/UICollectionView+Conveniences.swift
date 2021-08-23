// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension UICollectionView {

    public func register(_ cellType: UICollectionViewCell.Type) {
        register(cellType, forCellWithReuseIdentifier: cellType.objectName)
    }

    public func registerNibCell(_ type: UICollectionViewCell.Type) {
        let name = type.objectName
        register(UINib(nibName: name, bundle: type.bundle), forCellWithReuseIdentifier: name)
    }

    public func registerNibCells(_ types: UICollectionViewCell.Type...) {
        for type in types {
            registerNibCell(type)
        }
    }

    public func dequeue<CellType: UICollectionViewCell>(_ type: CellType.Type, for indexPath: IndexPath) -> CellType {
        dequeueReusableCell(withReuseIdentifier: type.objectName, for: indexPath) as! CellType
    }
}

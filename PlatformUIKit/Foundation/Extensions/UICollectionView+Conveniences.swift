//
//  UICollectionView+Conveniences.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 23/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public extension UICollectionView {
    
    func register(_ cellType: UICollectionViewCell.Type) {
        register(cellType, forCellWithReuseIdentifier: cellType.objectName)
    }
    
    func registerNibCell(_ type: UICollectionViewCell.Type) {
        let name = type.objectName
        register(UINib(nibName: name, bundle: type.bundle), forCellWithReuseIdentifier: name)
    }
    
    func registerNibCells(_ types: UICollectionViewCell.Type...) {
        for type in types {
            registerNibCell(type)
        }
    }
    
    func dequeue<CellType: UICollectionViewCell>(_ type: CellType.Type, for indexPath: IndexPath) -> CellType {
        dequeueReusableCell(withReuseIdentifier: type.objectName, for: indexPath) as! CellType
    }
}

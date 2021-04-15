//
//  UITableView+Conveniences.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 06/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import UIKit

public extension UITableView {
    
    // MARK: - Mutating accessors
    
    func insertFirst(with animation: RowAnimation = .automatic) {
        insertRows(at: [.firstRowInFirstSection], with: animation)
    }
    
    func deleteFirst(with animation: RowAnimation = .automatic) {
        deleteRows(at: [.firstRowInFirstSection], with: animation)
    }
    
    // MARK: - Register header / footer
    
    func register<HeaderType: UITableViewHeaderFooterView>(_ headerType: HeaderType.Type) {
        register(headerType, forHeaderFooterViewReuseIdentifier: headerType.objectName)
    }
    
    // MARK: - Register cell type
    
    func register<CellType: UITableViewCell>(_ cellType: CellType.Type) {
        register(cellType, forCellReuseIdentifier: cellType.objectName)
    }
    
    func register<CellType: UITableViewCell>(_ cellTypes: [CellType.Type]) {
        for type in cellTypes {
            register(type, forCellReuseIdentifier: type.objectName)
        }
    }
    
    // MARK: - Register cell name
    
    func registerHeaderView(_ name: String, bundle: Bundle = .main) {
        register(UINib(nibName: name, bundle: bundle), forHeaderFooterViewReuseIdentifier: name)
    }

    func registerNibCell(_ type: UITableViewCell.Type) {
        let name = type.objectName
        register(UINib(nibName: name, bundle: type.bundle), forCellReuseIdentifier: name)
    }

    func registerNibCells(_ types: UITableViewCell.Type...) {
        for type in types {
            registerNibCell(type)
        }
    }
    
    // MARK: - Dequeue accessors
    
    func dequeue<CellType: UITableViewCell>(_ type: CellType.Type, for indexPath: IndexPath) -> CellType {
        dequeueReusableCell(withIdentifier: type.objectName, for: indexPath) as! CellType
    }

    func dequeue<HeaderType: UITableViewHeaderFooterView>(_ type: HeaderType.Type) -> HeaderType {
        dequeueReusableHeaderFooterView(withIdentifier: type.objectName) as! HeaderType
    }
}

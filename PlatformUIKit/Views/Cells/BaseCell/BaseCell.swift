//
//  BaseCell.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 1/7/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public class BaseCell: UICollectionViewCell {
    
    public func configure(_ model: ContainerModel) {
        assertionFailure("Should be implemented by subclasses")
    }
    
    public func configure(_ model: CellModel) {
        assertionFailure("Should be implemented by subclasses")
    }
    
    public class func heightForProposedWidth(_ width: CGFloat, model: CellModel) -> CGFloat {
        0.0 // Cells should override this method.
    }
    
    public class func heightForProposedWidth(_ width: CGFloat, containerModel: ContainerModel) -> CGFloat {
        0.0 // Containers should override this method.
    }
    
    public class func sectionTitleFont() -> UIFont {
        Font(.branded(.montserratRegular), size: .custom(24.0)).result
    }
    
    public class func sectionTitleColor() -> UIColor {
        .black
    }
    
    // MARK: - Accessibility
    
    /// Implements initial cell accessibility property values.
    internal func applyAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .none
        shouldGroupAccessibilityChildren = false
    }
}

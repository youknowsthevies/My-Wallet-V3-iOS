//
//  TargetSelectionHeader.swift
//  PlatformUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 02/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public enum TargetSelectionHeaderType {
    case none
    case titledSection(TitledSectionHeaderModel)
    case section(SourceTargetSectionHeaderModel)
}

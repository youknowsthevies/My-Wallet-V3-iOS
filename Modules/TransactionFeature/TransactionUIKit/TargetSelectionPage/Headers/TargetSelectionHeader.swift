//
//  TargetSelectionHeader.swift
//  PlatformUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 02/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public enum TargetSelectionHeaderType: Equatable, Identifiable {
    case none
    case titledSection(TitledSectionHeaderModel)
    case section(SourceTargetSectionHeaderModel)

    public var id: String {
        switch self {
        case .none:
            return "none"
        case .titledSection(let model):
            return model.titleLabel.text + model.sectionTitleLabel.text
        case .section(let model):
            return model.sectionTitleLabel.text
        }
    }
}

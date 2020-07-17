//
//  SettingsSectionViewState.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum SettingsSectionViewState {
    /// The section is empty and should not be visible
    case empty
    
    /// The section has some data and show be visible
    case some(SettingsSectionViewModel)
    
    var viewModel: SettingsSectionViewModel? {
        switch self {
        case .empty:
            return nil
        case .some(let viewModel):
            return viewModel
        }
    }
}

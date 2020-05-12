//
//  AsyncPresenting.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/20/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// `SettingsAsyncPresenting` is used in a few presenters in `SettingsScreenPresenter`
/// (e.g. `BadgeCellPresenting`). If the cell is loading, the `SettingsScreenAction` that
/// is returned should be `.none`
public protocol AsyncPresenting {
    var isLoading: Bool { get }
}

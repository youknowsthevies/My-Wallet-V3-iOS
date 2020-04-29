//
//  DetailsScreenPresenterAPI.swift
//  PlatformUIKit
//
//  Created by Paulo on 01/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol DetailsScreenPresenterAPI: class {

    var buttons: [ButtonViewModel] { get }
    var cells: [DetailsScreen.CellType] { get }
    var titleView: Screen.Style.TitleView { get }
    var navigationBarAppearance: DetailsScreen.NavigationBarAppearance { get }

    func viewDidLoad()
    func navigationBarLeadingButtonPressed()
    func navigationBarTrailingButtonPressed()
}

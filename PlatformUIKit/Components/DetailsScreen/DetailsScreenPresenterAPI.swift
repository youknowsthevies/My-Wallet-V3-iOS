//
//  DetailsScreenPresenterAPI.swift
//  PlatformUIKit
//
//  Created by Paulo on 01/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift
import RxCocoa

public protocol DetailsScreenPresenterAPI: class {

    var buttons: [ButtonViewModel] { get }
    var cells: [DetailsScreen.CellType] { get }
    var titleView: Driver<Screen.Style.TitleView> { get }
    var titleViewRelay: BehaviorRelay<Screen.Style.TitleView> { get }
    var navigationBarAppearance: DetailsScreen.NavigationBarAppearance { get }
    var navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction { get }
    var navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction { get }

    var reloadRelay: PublishRelay<Void> { get }
    var reload: Signal<Void> { get }

    func viewDidLoad()

}

public extension DetailsScreenPresenterAPI {

    var buttons: [ButtonViewModel] { [] }

    func viewDidLoad() { /* NOOP */ }

    var reload: Signal<Void> {
        reloadRelay.asSignal()
    }

    var titleView: Driver<Screen.Style.TitleView> {
        titleViewRelay.asDriver()
    }
}


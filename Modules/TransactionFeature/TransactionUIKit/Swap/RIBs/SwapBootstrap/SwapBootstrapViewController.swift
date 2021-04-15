//
//  SwapBootstrapViewController.swift
//  TransactionUIKit
//
//  Created by Paulo on 30/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RIBs
import RxSwift

final class SwapBootstrapViewController: UIViewController, SwapBootstrapPresentable, SwapBootstrapViewControllable {

    func showLoading() {
        LoadingViewPresenter.shared.show(in: view, with: nil)
    }
}

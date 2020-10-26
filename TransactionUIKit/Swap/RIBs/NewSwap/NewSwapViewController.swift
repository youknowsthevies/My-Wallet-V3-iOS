//
//  NewSwapViewController.swift
//  TransactionUIKit
//
//  Created by Paulo on 12/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RIBs
import PlatformKit
import RxSwift
import UIKit

protocol NewSwapPresentableListener: class {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.

    func startSwapFlow(with pair: (CurrencyType, CurrencyType)?)
}

final class NewSwapViewController: UIViewController, NewSwapPresentable, NewSwapViewControllable {

    weak var listener: NewSwapPresentableListener?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Swap"
        let newSwap = UIButton(type: .system)
        newSwap.setTitle("New Swap", for: .normal)
        newSwap.addTarget(self, action: #selector(didTapNewSwap), for: .touchUpInside)
        newSwap.frame = CGRect(x: 40, y: 100, width: 100, height: 40)
        view.addSubview(newSwap)
        let predefined = UIButton(type: .system)
        predefined.setTitle("BTC -> ETH", for: .normal)
        predefined.addTarget(self, action: #selector(didTapPredefined), for: .touchUpInside)
        predefined.frame = CGRect(x: 40, y: 150, width: 100, height: 40)
        view.addSubview(predefined)
    }

    @objc private func didTapNewSwap() {
        listener?.startSwapFlow(with: nil)
    }

    @objc private func didTapPredefined() {
        listener?.startSwapFlow(with: (.crypto(.bitcoin), .crypto(.ethereum)))
    }
}

//
//  AmountInputViewController.swift
//  TransactionUIKit
//
//  Created by Paulo on 12/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RIBs
import RxSwift
import UIKit

protocol AmountInputPresentableListener: class {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.

    func didChoose(amount: Decimal)
}

final class AmountInputViewController: UIViewController, AmountInputPresentable, AmountInputViewControllable {

    weak var listener: AmountInputPresentableListener?
    private let label = UILabel(frame: .init(x: 20, y: 20, width: 150, height: 50))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(label)
        let button = UIButton(type: .system)
        button.frame = .init(x: 20, y: 90, width: 150, height: 50)
        button.setTitle("Buy $15", for: .normal)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        view.addSubview(button)
    }

    func configure(withFrom from: String, to: String) {
        label.text = "Buy \(to) using \(from)"
    }

    @objc private func didTapButton() {
        listener?.didChoose(amount: Decimal(15))
    }
}

//
//  WebLoginScreenViewController.swift
//  Blockchain
//
//  Created by Paulo on 20/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import PlatformUIKit
import PlatformKit
import RxRelay
import RxSwift
import RxCocoa

final class WebLoginScreenViewController: BaseScreenViewController {

    @IBOutlet var firstBullet: UILabel!
    @IBOutlet var firstText: UILabel!
    @IBOutlet var secondBullet: UILabel!
    @IBOutlet var secondText: UILabel!
    @IBOutlet var thirdBullet: UILabel!
    @IBOutlet var thirdText: UILabel!
    @IBOutlet var actionButon: ButtonView!
    @IBOutlet var securityAlert: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var qrCodeView: UIView!
    @IBOutlet var qrCodeSecurityAlertTop: UILabel!
    @IBOutlet var qrCodeSecurityAlertBottom: UILabel!

    private let disposeBag = DisposeBag()
    private let presenter: WebLoginScreenPresenter

    init(presenter: WebLoginScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: WebLoginScreenViewController.objectName, bundle: nil)
    }
    @available(*, unavailable) required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        set(barStyle: presenter.barStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: .none)
        titleViewStyle = presenter.titleView
        firstBullet.content = presenter.bullet1Label
        firstText.content = presenter.step1Label
        secondBullet.content = presenter.bullet2Label
        secondText.content = presenter.step2Label
        thirdBullet.content = presenter.bullet3Label
        thirdText.content = presenter.step3Label
        securityAlert.content = presenter.securityAlert
        qrCodeSecurityAlertTop.content = presenter.qrCodeScurityAlertTop
        qrCodeSecurityAlertBottom.content = presenter.qrCodeScurityAlertBottom
        actionButon.viewModel = presenter.actionButtonModel
        presenter
            .qrCodeImage
            .asObservable()
            .bind(to: imageView.rx.image)
            .disposed(by: disposeBag)
        presenter.qrCodeVisibility
            .map { $0.isHidden }
            .drive(qrCodeView.rx.isHidden)
            .disposed(by: disposeBag)
    }
}

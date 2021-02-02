//
//  WebLoginScreenViewController.swift
//  Blockchain
//
//  Created by Paulo on 20/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift

final class WebLoginScreenViewController: BaseScreenViewController {

    @IBOutlet private var tableView: InstructionTableView!
    @IBOutlet private var actionButon: ButtonView!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var qrCodeView: UIView!
    @IBOutlet private var noticeView: NoticeView!

    private let disposeBag = DisposeBag()
    private let presenter: WebLoginScreenPresenter

    init(presenter: WebLoginScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: WebLoginScreenViewController.objectName, bundle: nil)
    }
    @available(*, unavailable) required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        set(barStyle: presenter.barStyle, trailingButtonStyle: .close)
        titleViewStyle = presenter.titleView
        noticeView.viewModel = presenter.noticeViewModel
        actionButon.viewModel = presenter.actionButtonModel
        tableView.viewModels = presenter.instructionViewModels
        presenter
            .qrCodeImage
            .asObservable()
            .bindAndCatch(to: imageView.rx.image)
            .disposed(by: disposeBag)
        presenter.qrCodeVisibility
            .map { $0.isHidden }
            .drive(qrCodeView.rx.isHidden)
            .disposed(by: disposeBag)
        presenter.qrCodeVisibility
            .map { !$0.isHidden }
            .drive(tableView.rx.isHidden)
            .disposed(by: disposeBag)
    }
}

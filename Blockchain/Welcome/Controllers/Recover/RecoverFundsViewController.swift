// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxCocoa
import RxSwift
import UIKit

final class RecoverFundsViewController: BaseScreenViewController {

    // MARK: Private IBOutlets

    @IBOutlet private var mnemonicTextView: MnemonicTextView!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var continueButtonView: ButtonView!

    private var keyboardInteractionController: KeyboardInteractionController!

    // MARK: - Injected

    private let presenter: RecoverFundsScreenPresenter
    private let dismissHandler: (() -> Void)?

    // MARK: - Setup

    init(presenter: RecoverFundsScreenPresenter, dismissHandler: (() -> Void)? = nil) {
        self.presenter = presenter
        self.dismissHandler = dismissHandler
        super.init(nibName: RecoverFundsViewController.objectName, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        set(
            barStyle: presenter.navBarStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: presenter.trailingButton
        )
        titleViewStyle = presenter.titleStyle
        descriptionLabel.textColor = .descriptionText
        keyboardInteractionController = KeyboardInteractionController(in: self)
        continueButtonView.viewModel = presenter.continueButtonViewModel
        mnemonicTextView.setup(
            viewModel: presenter.mnemonicTextViewModel,
            keyboardInteractionController: keyboardInteractionController
        )
    }

    override func navigationBarTrailingButtonPressed() {
        dismissHandler?()
    }
}

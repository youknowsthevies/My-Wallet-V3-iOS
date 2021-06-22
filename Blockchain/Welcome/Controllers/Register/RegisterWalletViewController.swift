// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxSwift
import ToolKit

/// This class represents the wallet creation form
final class RegisterWalletViewController: BaseScreenViewController {

    // MARK: Private IBOutlets

    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var emailTextField: TextFieldView!
    @IBOutlet private var passwordTextField: PasswordTextFieldView!
    @IBOutlet private var confirmPasswordTextField: PasswordTextFieldView!
    @IBOutlet private var termsOfUseTextView: InteractableTextView!
    @IBOutlet private var buttonView: ButtonView!

    private var keyboardInteractionController: KeyboardInteractionController!

    // MARK: - Injected

    private let presenter: RegisterWalletScreenPresenter
    private let dismissHandler: (() -> Void)?

    // MARK: - Accessors

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(presenter: RegisterWalletScreenPresenter, dismissHandler: (() -> Void)? = nil) {
        self.presenter = presenter
        self.dismissHandler = dismissHandler
        super.init(nibName: RegisterWalletViewController.objectName, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        unimplemented()
    }

    // MARK: - Lifecycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        set(
            barStyle: presenter.navBarStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: presenter.trailingButton
        )
        titleViewStyle = presenter.titleStyle
        keyboardInteractionController = KeyboardInteractionController(
            in: self,
            disablesToolBar: DevicePresenter.type == .superCompact
        )
        emailTextField.setup(
            viewModel: presenter.emailTextFieldViewModel,
            keyboardInteractionController: keyboardInteractionController
        )
        passwordTextField.setup(
            viewModel: presenter.passwordTextFieldViewModel,
            keyboardInteractionController: keyboardInteractionController
        )
        confirmPasswordTextField.setup(
            viewModel: presenter.confirmPasswordTextFieldViewModel,
            keyboardInteractionController: keyboardInteractionController
        )

        if DevicePresenter.type == .superCompact {
            let topInset: CGFloat = 8
            emailTextField.topInset = topInset
            passwordTextField.topInset = topInset
            confirmPasswordTextField.topInset = topInset
        }

        // Setup button
        buttonView.viewModel = presenter.buttonViewModel
        buttonView.viewModel.tapRelay
            .dismissKeyboard(using: keyboardInteractionController)
            .subscribe()
            .disposed(by: disposeBag)

        // Setup the terms text view
        termsOfUseTextView.layoutToSuperview(axis: .horizontal, offset: 24)
        termsOfUseTextView.layout(edge: .top, to: .bottom, of: stackView, offset: 16)
        termsOfUseTextView.viewModel = presenter.termsOfUseTextViewModel
        view.layoutIfNeeded()
        termsOfUseTextView.setupHeight()
        presenter.viewDidLoad()
    }

    override func navigationBarTrailingButtonPressed() {
        dismissHandler?()
    }
}

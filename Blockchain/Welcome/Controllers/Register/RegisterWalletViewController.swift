//
//  RegisterWalletViewController.swift
//  Blockchain
//
//  Created by AlexM on 10/3/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxCocoa
import RxSwift

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
    
    // MARK: - Accessors
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(presenter: RegisterWalletScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: RegisterWalletViewController.objectName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        set(barStyle: presenter.navBarStyle, leadingButtonStyle: .back)
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
}

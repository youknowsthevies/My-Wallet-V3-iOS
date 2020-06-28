//
//  UpdateMobileScreenViewController.swift
//  Blockchain
//
//  Created by AlexM on 2/10/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxSwift
import RxCocoa

final class UpdateMobileScreenViewController: BaseScreenViewController {
    
    // MARK: - Private IBOutlets
    
    @IBOutlet private var updateButtonView: ButtonView!
    @IBOutlet private var continueButtonView: ButtonView!
    @IBOutlet private var disable2FALabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet fileprivate var badgeView: BadgeView!
    @IBOutlet private var mobileNumberTextFieldView: TextFieldView!
    
    // MARK: - Private Properties
    
    fileprivate var badgeShimmeringView: ShimmeringView!
    private var keyboardInteractionController: KeyboardInteractionController!
    private let presenter: UpdateMobileScreenPresenter
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    
    init(presenter: UpdateMobileScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: UpdateMobileScreenViewController.objectName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shimmer()
        set(barStyle: presenter.barStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: .none)
        titleViewStyle = presenter.titleView
        keyboardInteractionController = KeyboardInteractionController(in: self)
        descriptionLabel.content = presenter.descriptionLabel
        mobileNumberTextFieldView.setup(
            viewModel: presenter.textField,
            keyboardInteractionController: keyboardInteractionController
        )
        continueButtonView.viewModel = presenter.continueButtonViewModel
        updateButtonView.viewModel = presenter.updateButtonViewModel
        disable2FALabel.content = presenter.disable2FALabel
        
        presenter.disable2FASMSVisibility
            .map { $0.isHidden }
            .drive(disable2FALabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        presenter.continueVisibility
            .map { $0.isHidden }
            .drive(continueButtonView.rx.isHidden)
            .disposed(by: disposeBag)
        
        presenter.updateVisibility
            .map { $0.isHidden }
            .drive(updateButtonView.rx.isHidden)
            .disposed(by: disposeBag)
        
        presenter.badgeState
            .bindAndCatch(to: rx.badgeViewModel)
            .disposed(by: disposeBag)
    }
    
    /// Should be called once when the parent view loads
    private func shimmer() {
        badgeShimmeringView = ShimmeringView(
            in: self.view,
            anchorView: badgeView,
            size: .init(width: 75, height: 24)
        )
    }
}

// MARK: - Rx

extension Reactive where Base: UpdateMobileScreenViewController {
    var badgeViewModel: Binder<BadgeAsset.State.BadgeItem.Presentation> {
        return Binder(base) { view, state in
            let loading = {
                view.badgeShimmeringView.start()
            }
            
            switch state {
            case .loading:
                UIView.animate(withDuration: 0.5, animations: loading)
            case .loaded(next: let value):
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .transitionCrossDissolve, animations: {
                    view.badgeView.viewModel = value.viewModel
                    view.badgeShimmeringView.stop()
                }, completion: nil)
            }
        }
    }
}


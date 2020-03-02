//
//  SimpleBuyKYCPendingViewController.swift
//  Blockchain
//
//  Created by Paulo on 22/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PlatformUIKit

final class SimpleBuyKYCPendingViewController: BaseScreenViewController {

    // MARK: - Private IBOutlets

    @IBOutlet private var actionButton: ButtonView!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    private var spinnerView: LoadingAnimatingView!

    // MARK: - Properties

    private let presenter: SimpleBuyKYCPendingPresenter
    private let disposeBag = DisposeBag()

    // MARK: - Init

    init(presenter: SimpleBuyKYCPendingPresenter) {
        self.presenter = presenter
        super.init(nibName: SimpleBuyKYCPendingViewController.objectName, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSpinnerView()
        setupAccessibility()
        presenter
            .model
            .drive(rx.viewModel)
            .disposed(by: disposeBag)
    }

    // MARK: - Setup

    private func setupAccessibility() {
        titleLabel.accessibilityIdentifier = presenter.titleAccessibility
        subtitleLabel.accessibilityIdentifier = presenter.subtitleAccessibility
        actionButton.accessibilityIdentifier = presenter.buttonAccessibility
    }

    private func setupSpinnerView() {
        spinnerView = LoadingAnimatingView(
            diameter: 52,
            strokeColor: .secondary,
            strokeBackgroundColor: UIColor.secondary.withAlphaComponent(0.3),
            fillColor: .clear
        )
        spinnerView.isHidden = true
        view.addSubview(spinnerView)
        spinnerView.layout(edges: .bottom, .centerX, to: imageView)
        spinnerView.layout(size: CGSize(width: 52, height: 52))
    }

    private func setupNavigationBar() {
        titleViewStyle = .text(value: presenter.title)
        set(barStyle: .lightContent(ignoresStatusBar: false, background: .navigationBarBackground))
    }

    // MARK: - View Update

    fileprivate func update(with model: SimpleBuyKYCPendingViewModel) {
        titleLabel.attributedText = model.title
        subtitleLabel.attributedText = model.subtitle

        switch model.asset {
        case .loading:
            imageView.isHidden = true
            spinnerView.isHidden = false
            spinnerView.animate()
        case .image(let image):
            imageView.isHidden = false
            spinnerView.isHidden = true
            imageView.image = image.image
            spinnerView.stop()
        }

        if let buttonModel = model.button {
            actionButton.viewModel = buttonModel
            actionButton.isHidden = false
        } else {
            actionButton.isHidden = true
        }
    }
}

extension Reactive where Base: SimpleBuyKYCPendingViewController {
    var viewModel: Binder<SimpleBuyKYCPendingViewModel> {
        return Binder(base) { viewController, viewModel in
            viewController.update(with: viewModel)
        }
    }
}

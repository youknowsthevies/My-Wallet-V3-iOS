//
//  PendingStateViewController.swift
//  Blockchain
//
//  Created by Paulo on 22/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa

public final class PendingStateViewController: BaseScreenViewController {

    // MARK: - Types
    
    private typealias AccessibilityId = Accessibility.Identifier.PendingStateScreen
    
    // MARK: - Private IBOutlets

    @IBOutlet private var actionButton: ButtonView!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    private var spinnerView: LoadingAnimatingView!

    // MARK: - Properties

    private let presenter: PendingStatePresenterAPI
    private let disposeBag = DisposeBag()

    // MARK: - Init

    public required init(presenter: PendingStatePresenterAPI) {
        self.presenter = presenter
        super.init(nibName: PendingStateViewController.objectName, bundle: .platformUIKit)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSpinnerView()
        setupAccessibility()
        presenter.viewModel
            .drive(rx.viewModel)
            .disposed(by: disposeBag)
        presenter.viewDidLoad()
    }
    
    // MARK: - Setup

    private func setupAccessibility() {
        titleLabel.accessibilityIdentifier = AccessibilityId.titleLabel
        subtitleLabel.accessibilityIdentifier = AccessibilityId.subtitleLabel
        actionButton.accessibilityIdentifier = AccessibilityId.button
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
        set(barStyle: .darkContent(ignoresStatusBar: false, background: .white))
    }

    // MARK: - View Update

    fileprivate func update(with model: PendingStateViewModel) {
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

// MARK: - Rx

extension Reactive where Base: PendingStateViewController {
    var viewModel: Binder<PendingStateViewModel> {
        return Binder(base) { viewController, viewModel in
            viewController.update(with: viewModel)
        }
    }
}

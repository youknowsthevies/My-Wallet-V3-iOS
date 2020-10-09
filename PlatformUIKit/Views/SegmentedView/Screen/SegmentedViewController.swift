//
//  DoubleAccountPickerViewController.swift
//  PlatformUIKit
//
//  Created by Paulo on 28/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import ToolKit

/// `SegmentedViewController` is a easy to used ViewController containing a `SegmentedView`
/// as `titleView` of it's `navigationItem`.
public final class SegmentedViewController: BaseScreenViewController {

    private lazy var segmentedView = SegmentedView()
    private let presenter: SegmentedViewScreenPresenting
    private let rootViewController: SegmentedTabViewController
    private let disposeBag = DisposeBag()

    required init?(coder: NSCoder) { unimplemented() }
    public init(presenter: SegmentedViewScreenPresenting) {
        self.presenter = presenter
        self.rootViewController = SegmentedTabViewController(items: presenter.items)
        super.init(nibName: nil, bundle: nil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        segmentedView.layout(dimension: .width, to: 196)
        segmentedView.viewModel = presenter.segmentedViewModel
        setupNavigationBar()
        add(child: rootViewController)
        presenter.itemIndexSelected
            .compactMap { $0 }
            .bindAndCatch(to: rootViewController.itemIndexSelectedRelay)
            .disposed(by: disposeBag)
    }

    private func setupNavigationBar() {
        set(barStyle: presenter.barStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: presenter.trailingButton)
        titleViewStyle = .view(value: segmentedView)
    }

    public override func navigationBarLeadingButtonPressed() {
        presenter.leadingButtonTapRelay.accept(())
    }

    public override func navigationBarTrailingButtonPressed() {
        presenter.trailingButtonTapRelay.accept(())
    }
}

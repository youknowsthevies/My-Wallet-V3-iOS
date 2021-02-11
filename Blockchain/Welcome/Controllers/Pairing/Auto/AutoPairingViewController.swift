//
//  AutoPairingViewController.swift
//  Blockchain
//
//  Created by Daniel Huri on 16/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

/// The screen responsible for auto pairing
final class AutoPairingViewController: BaseScreenViewController {

    // MARK: - Properties
    
    private var viewFrame: CGRect {
        guard let window = UIApplication.shared.keyWindow else {
            fatalError("Trying to get key window before it was set!")
        }
        let width = window.bounds.size.width
        let height = window.bounds.size.height - Constants.Measurements.DefaultHeaderHeight
        return CGRect(x: 0, y: 0, width: width, height: height)
    }
    
    private let presenter: AutoPairingScreenPresenter
    private var viewFinderViewController: UIViewController!
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(presenter: AutoPairingScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: AutoPairingViewController.objectName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        set(barStyle: presenter.navBarStyle, leadingButtonStyle: .back)
        titleViewStyle = presenter.titleStyle
        presenter.fallbackAction
            .emit(to: rx.fallbackAction)
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        start()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stop()
    }
        
    fileprivate func stop() {
        viewFinderViewController?.remove()
    }
    
    fileprivate func start() {
        viewFinderViewController = presenter.scannerBuilder.build()!
        viewFinderViewController.view.frame = viewFrame
        add(child: viewFinderViewController)
    }
}

/// Extension for rx that makes `UIView` properties reactive
extension Reactive where Base: AutoPairingViewController {
    var fallbackAction: Binder<AutoPairingScreenPresenter.FallbackAction> {
        Binder(base) { viewController, action in
            switch action {
            case .stop:
                viewController.stop()
            case .retry:
                viewController.start()
            case .cancel:
                viewController.navigationBarLeadingButtonPressed()
            }
        }
    }
}

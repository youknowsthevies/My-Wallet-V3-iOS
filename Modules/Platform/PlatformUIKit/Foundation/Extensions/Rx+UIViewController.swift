//
//  Rx+UIViewController.swift
//  PlatformUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 27/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

public extension Reactive where Base: UIViewController {

    /// Reactive wrapper for `UIViewController.viewDidLoad`
    var viewDidLoad: ControlEvent<Void> {
        let source = methodInvoked(#selector(Base.viewDidLoad))
            .map { _ in }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIViewController.viewWillAppear`
    var viewWillAppear: ControlEvent<Bool> {
        let source = methodInvoked(#selector(Base.viewWillAppear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIViewController.viewDidAppear`
    var viewDidAppear: ControlEvent<Bool> {
        let source = methodInvoked(#selector(Base.viewDidAppear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIViewController.viewWillDisappear`
    var viewWillDisappear: ControlEvent<Bool> {
        let source = methodInvoked(#selector(Base.viewWillDisappear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIViewController.viewDidDisappear`
    var viewDidDisappear: ControlEvent<Bool> {
        let source = methodInvoked(#selector(Base.viewDidDisappear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIViewController.viewWillLayoutSubviews`
    var viewWillLayoutSubviews: ControlEvent<Void> {
        let source = methodInvoked(#selector(Base.viewWillLayoutSubviews)).map { _ in }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIViewController.viewDidLayoutSubviews`
    var viewDidLayoutSubviews: ControlEvent<Void> {
        let source = methodInvoked(#selector(Base.viewDidLayoutSubviews)).map { _ in }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIViewController.willMove`
    var willMoveToParentViewController: ControlEvent<UIViewController?> {
        let source = methodInvoked(#selector(Base.willMove)).map { $0.first as? UIViewController }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIViewController.didMove`
    var didMoveToParentViewController: ControlEvent<UIViewController?> {
        let source = methodInvoked(#selector(Base.didMove)).map { $0.first as? UIViewController }
        return ControlEvent(events: source)
    }

    /// Observable stream that streams if the view controller is visible or not
    var isVisible: Observable<Bool> {
        let viewDidAppearObservable = self.base.rx.viewDidAppear.map { _ in true }
        let viewWillDisappearObservable = self.base.rx.viewWillDisappear.map { _ in false }
        return Observable<Bool>.merge(viewDidAppearObservable, viewWillDisappearObservable)
            .share(replay: 1, scope: .whileConnected)
    }

    /// Reactive wrapper for `UIViewController.viewWillAppear`
    ///
    ///  **Note** this will be called once, hence the `firstTime` prefix
    var firstTimeViewWillAppear: Observable<Void> {
        self.sentMessage(#selector(Base.viewWillAppear)).map { _ in () }
            .take(1)
            .share(replay: 1, scope: .whileConnected)
    }

    /// Reactive wrapper for `UIViewController.viewDidAppear` but called once
    ///
    ///  **Note** this will be called once, hence the `firstTime` prefix
    var firstTimeViewDidAppear: Observable<Void> {
        self.sentMessage(#selector(Base.viewDidAppear)).map { _ in () }
            .take(1)
            .share(replay: 1, scope: .whileConnected)
    }

}

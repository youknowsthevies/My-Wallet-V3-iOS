//
//  ObservableType+Loading.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 12/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public extension PrimitiveSequence where Trait == SingleTrait {
    
    /// Shows the loader
    func show(loader: LoadingViewPresenting,
              style: LoadingViewPresenter.LoadingViewStyle = .activityIndicator,
              text: String? = nil) -> Single<Element> {
        self.do(onSuccess: { _ in
            loader.show(with: style, text: text)
        })
    }
    
    /// Hides the loader
    func hide(loader: LoadingViewPresenting) -> Single<Element> {
        self.do(onSuccess: { _ in
            loader.hide()
        })
    }
    
    /// Show the loader and returns `Element`
    func showOnSubscription(loader: LoadingViewPresenting,
                            style: LoadingViewPresenter.LoadingViewStyle = .activityIndicator,
                            text: String? = nil) -> Single<Element> {
        self.do(onSubscribe: {
            loader.show(with: text)
        })
    }
    
    /// Hides the loader and returns `Element`
    func hideOnDisposal(loader: LoadingViewPresenting) -> Single<Element> {
        self.do(onDispose: {
            loader.hide()
        })
    }
    
    /// Shows and hides the loader
    func handleLoaderForLifecycle(loader: LoadingViewPresenting,
                                  style: LoadingViewPresenter.LoadingViewStyle = .activityIndicator,
                                  text: String? = nil) -> Single<Element> {
        self.do(onSubscribe: {
            loader.show(with: style, text: text)
        }, onDispose: {
            loader.hide()
        })
    }
}

/// Extension for `ObservableType` that enables the loader to take part in a chain of observables
public extension ObservableType {
    
    /// Show the loader and returns `Element`
    func show(loader: LoadingViewPresenting,
              style: LoadingViewPresenter.LoadingViewStyle = .activityIndicator,
              text: String? = nil) -> Observable<Element> {
        self.do(onNext: { _ in
            loader.show(with: style, text: text)
        })
    }
    
    /// Hides the loader and returns `Element`
    func hide(loader: LoadingViewPresenting) -> Observable<Element> {
        self.do(onNext: { _ in
            loader.hide()
        })
    }
}

/// Extension for `ObservableType` that enables the loader to take part in a chain of observables
public extension ObservableType {
    
    /// Shows and hides the loader
    func handleLoaderForLifecycle(loader: LoadingViewPresenting,
                                  style: LoadingViewPresenter.LoadingViewStyle = .activityIndicator,
                                  text: String? = nil) -> Observable<Element> {
        self.do(onSubscribe: {
            loader.show(with: style, text: text)
        }, onDispose: {
            loader.hide()
        })
    }
    
    /// Shows the loader upon subscription
    func showLoaderOnSubscription(loader: LoadingViewPresenting,
                                  text: String? = nil) -> Observable<Element> {
        self.do(onSubscribe: {
            loader.show(with: text)
        })
    }
    
    /// Hides the loader upon disposal
    func hideLoaderOnDisposal(loader: LoadingViewPresenting) -> Observable<Element> {
        self.do(onDispose: {
            loader.hide()
        })
    }
}

/// Extension for any component that inherits `ReactiveLoaderPresenting`.
/// Enables Rx for displaying and hiding the loader
public extension Reactive where Base: ReactiveLoaderPresenting {
    
    /// Show the loader and returns `Element`
    func show(loader: LoadingViewPresenting,
              style: LoadingViewPresenter.LoadingViewStyle = .activityIndicator,
              text: String? = nil) -> Completable {
        Completable.create { completable -> Disposable in
            loader.show(with: style, text: text)
            completable(.completed)
            return Disposables.create()
        }
    }
    
    /// Show the loader and returns `Element`
    func hide(loader: LoadingViewPresenting) -> Completable {
        Completable.create { completable -> Disposable in
            loader.hide()
            completable(.completed)
            return Disposables.create()
        }
    }
}

public extension PrimitiveSequence where Trait == CompletableTrait, Element == Never {
    
    /// Shows the loader
    func show(loader: LoadingViewPresenting,
              style: LoadingViewPresenter.LoadingViewStyle = .activityIndicator,
              text: String? = nil) -> Completable {
        self.do(onCompleted: {
            loader.show(with: style, text: text)
        })
    }
    
    /// Hides the loader
    func hide(loader: LoadingViewPresenting) -> Completable {
        self.do(onCompleted: {
            loader.hide()
        })
    }
    
    /// Show the loader and returns `Element`
    func showOnSubscription(loader: LoadingViewPresenting,
                            style: LoadingViewPresenter.LoadingViewStyle = .activityIndicator,
                            text: String? = nil) -> Completable {
        self.do(onSubscribe: {
            loader.show(with: text)
        })
    }
    
    /// Hides the loader and returns `Element`
    func hideOnDisposal(loader: LoadingViewPresenting) -> Completable {
        self.do(onDispose: {
            loader.hide()
        })
    }
    
    /// Shows and hides the loader
    func handleLoaderForLifecycle(loader: LoadingViewPresenting,
                                  style: LoadingViewPresenter.LoadingViewStyle = .activityIndicator,
                                  text: String? = nil) -> Completable {
        self.do(onSubscribe: {
            loader.show(with: style, text: text)
        }, onDispose: {
            loader.hide()
        })
    }
}

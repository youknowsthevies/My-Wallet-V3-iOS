//
//  Rx+BottomAlertSheet.swift
//  PlatformUIKit
//
//  Created by AlexM on 7/19/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public extension PrimitiveSequenceType where Trait == CompletableTrait, Element == Never {
    
    /// Show the alert and returns `Element`
    func showSheetAfterCompletion(bottomAlertSheet: BottomAlertSheet) -> Completable {
        self.do(afterCompleted: {
            bottomAlertSheet.show()
        })
    }
    
    /// Hides the alert and returns `Element`
    func hideBottomSheetOnCompletionOrError(bottomAlertSheet: BottomAlertSheet) -> Completable {
        self.do(onError: { _ in
            bottomAlertSheet.hide()
        }, onCompleted: {
            bottomAlertSheet.hide()
        })
    }
    
    /// Show the alert and returns `Element`
    func showSheetAfterFailure(bottomAlertSheet: BottomAlertSheet) -> Completable {
        self.do(afterError: { _ in
            bottomAlertSheet.show()
        })
    }
    
    /// Show the alert and returns `Element`
    func showSheetOnSubscription(bottomAlertSheet: BottomAlertSheet) -> Completable {
        self.do(onSubscribe: {
            bottomAlertSheet.show()
        })
    }
}

public extension PrimitiveSequence where Trait == SingleTrait {
    
    /// Show the alert and returns `Element`
    func showSheetAfterSuccess(bottomAlertSheet: BottomAlertSheet) -> Single<Element> {
        self.do(afterSuccess: { _ in
            bottomAlertSheet.show()
        })
    }
    
    /// Show the alert and returns `Element`
    func showSheetAfterFailure(bottomAlertSheet: BottomAlertSheet) -> Single<Element> {
        self.do(afterError: { _ in
            bottomAlertSheet.show()
        })
    }
    
    /// Show the alert and returns `Element`
    func showSheetOnSubscription(bottomAlertSheet: BottomAlertSheet) -> Single<Element> {
        self.do(onSubscribe: {
            bottomAlertSheet.show()
        })
    }
    
    /// Hides the alert and returns `Element`
    func hideBottomSheetOnDisposal(bottomAlertSheet: BottomAlertSheet) -> Single<Element> {
        self.do(onDispose: {
            bottomAlertSheet.hide()
        })
    }
    
    /// Hides the alert and returns `Element`
    func hideBottomSheetOnSuccessOrError(bottomAlertSheet: BottomAlertSheet) -> Single<Element> {
        self.do(onSuccess: { _ in
            bottomAlertSheet.hide()
        }, onError: { _ in
            bottomAlertSheet.hide()
        })
    }
}

/// Extension for `ObservableType` that enables the loader to take part in a chain of observables
public extension ObservableType {
    
    /// Shows the alert upon subscription
    func showSheetOnSubscription(bottomAlertSheet: BottomAlertSheet) -> Observable<Element> {
        self.do(onSubscribe: {
            bottomAlertSheet.show()
        })
    }
    
    /// Hides the alert upon disposal
    func hideBottomSheetOnDisposal(bottomAlertSheet: BottomAlertSheet) -> Observable<Element> {
        self.do(onDispose: {
            bottomAlertSheet.hide()
        })
    }
}

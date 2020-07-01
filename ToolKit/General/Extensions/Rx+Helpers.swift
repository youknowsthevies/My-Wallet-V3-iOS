//
//  Rx+Helpers.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/1/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public extension CompositeDisposable {
    @discardableResult func insertWithDiscardableResult(_ disposable: Disposable) -> CompositeDisposable.DisposeKey? {
        self.insert(disposable)
    }
}

public extension ObservableType {
    func optional() -> Observable<Element?> {
        self.asObservable().map { e -> Element? in
            e
        }
    }
    
    func mapToVoid() -> Observable<Void> {
        map { _ in () }
    }
}

public extension PrimitiveSequenceType where Trait == SingleTrait {
    func optional() -> Single<Element?> {
        self.map { e -> Element? in
            e
        }
    }
    
    func mapToVoid() -> Single<Void> {
        map { _ in () }
    }
}

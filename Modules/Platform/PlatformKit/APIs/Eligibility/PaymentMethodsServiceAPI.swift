// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

/// Fetches the available payment methods
public protocol PaymentMethodsServiceAPI: class {
    var paymentMethods: Observable<[PaymentMethod]> { get }
    var paymentMethodsSingle: Single<[PaymentMethod]> { get }
    var supportedCardTypes: Single<Set<CardType>> { get }
    func fetch() -> Observable<[PaymentMethod]>
    func refresh() -> Completable
}

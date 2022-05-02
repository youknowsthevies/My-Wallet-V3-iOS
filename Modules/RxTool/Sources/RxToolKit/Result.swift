// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

extension Result {
    public var single: Single<Success> {
        switch self {
        case .success(let value):
            return Single.just(value)
        case .failure(let error):
            return Single.error(error)
        }
    }
}

extension Result {
    public var completable: Completable {
        switch self {
        case .success:
            return Completable.empty()
        case .failure(let error):
            return Completable.error(error)
        }
    }
}

extension SingleEvent {
    public static func error(_ error: Failure) -> Self {
        .failure(error)
    }
}

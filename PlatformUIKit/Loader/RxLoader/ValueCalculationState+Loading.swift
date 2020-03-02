//
//  ValueCalculationState+Loading.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 14/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit
import PlatformKit

extension ValueCalculationState {
    public func handle(loadingViewPresenter: LoadingViewPresenting, text: String? = nil) {
        switch self {
        case .calculating, .invalid(.empty):
            loadingViewPresenter.showCircular(with: text)
        case .invalid(.valueCouldNotBeCalculated), .value:
            loadingViewPresenter.hide()
        }
    }
}

extension ObservableType {
    public func handle<Value>(loadingViewPresenter: LoadingViewPresenting, text: String? = nil) -> Observable<ValueCalculationState<Value>> where Element == ValueCalculationState<Value> {
        self.do(
            onNext: { state in
                state.handle(loadingViewPresenter: loadingViewPresenter, text: text)
            }
        )
    }
}

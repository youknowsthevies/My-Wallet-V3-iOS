// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift

extension Reactive where Base: UIView {

    /// Bindable sink for `Accessibility`
    public var accessibility: Binder<Accessibility> {
        Binder(self.base) { view, accessibility in
            view.accessibility = accessibility
        }
    }
}

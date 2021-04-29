// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UIResponder {
    public var motionEnded: ControlEvent<UIEvent.EventSubtype> {
        let source = methodInvoked(#selector(UIResponder.motionEnded(_:with:)))
            .map { args -> UIEvent.EventSubtype in
                guard let type = args.first as? Int else {
                    return .none
                }
                return UIEvent.EventSubtype(rawValue: type) ?? .none
            }
        return ControlEvent(events: source)
    }
}

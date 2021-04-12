//
//  ViewPresenter.swift
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxCocoa

/// An abstract class that doesn't do much: it's only used for communication across modules
open class ViewPresenter {
    
    /// Required to initialize subsclasses
    public init() {}
    
    /// Override me. The default implementation checks for identity equality.
    open func isEqual(to other: ViewPresenter) -> Bool {
        self === other
    }
    
}

extension ViewPresenter: Equatable {
    
    /// Override `isEqual(to:)` to customize the behaviour of this method.
    /// The reliance on `isEqual(to:)` is required because this is a static method implemented by an abstract class.
    public static func == (lhs: ViewPresenter, rhs: ViewPresenter) -> Bool {
        lhs.isEqual(to: rhs)
    }
    
}

open class CurrencyViewPresenter: ViewPresenter {
    
    /// Override me. Defailt implementation returns nil.
    open var tap: Signal<CurrencyType>? {
        return nil
    }
    
}

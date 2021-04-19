//
//  ViewPresenter.swift
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxCocoa

/// An abstract class that doesn't do much: it's only used for communication across modules
open class ViewPresenter: Equatable {
    
    /// Required to initialize subsclasses
    public init() {}
    
    public static func == (lhs: ViewPresenter, rhs: ViewPresenter) -> Bool {
        lhs === rhs
    }
    
}

open class CurrencyViewPresenter: ViewPresenter {
    
    /// Override me. Defailt implementation returns nil.
    open var tap: Signal<CurrencyType>? {
        nil
    }
    
}

//
//  LabeledButtonViewModelAPI.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 22/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa

/// An interaction later for a label view.
public protocol LabeledButtonViewModelAPI: class {
    
    /// Associate an element with the content
    associatedtype Element
    
    /// Enables to bind the element once tapped
    var elementOnTap: Signal<Element> { get }
    
    /// Accepts taps
    var tapRelay: PublishRelay<Void> { get }
    
    /// Determines the background color
    var backgroundColor: Color { get }
    
    /// Determines the content of the button
    var content: Driver<ButtonContent> { get }
}

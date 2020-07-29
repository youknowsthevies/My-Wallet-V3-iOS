//
//  Presenter.swift
//  PlatformUIKit
//
//  Created by Daniel on 16/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//  Implementation Reference: https://github.com/uber/RIBs (RIBs Architecture by Uber)
//

/// Presenters should subclass `Presenter`
open class Presenter {

    private let interactable: Interactable
    
    public init(interactable: Interactable) {
        self.interactable = interactable
    }
    
    open func viewDidLoad() {
        // No-Op
    }
    
    open func viewWillAppear() {
        interactable.activate()
    }
    
    open func viewDidDisappear() {
        interactable.deactivate()
    }
}

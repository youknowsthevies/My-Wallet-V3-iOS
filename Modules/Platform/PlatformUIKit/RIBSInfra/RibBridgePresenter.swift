//
//  RibBridgePresenter.swift
//  PlatformUIKit
//
//  Created by Daniel on 16/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//  Implementation Reference: https://github.com/uber/RIBs (RIBs Architecture by Uber)
//

import RIBs

/// Presenters should subclass `Presenter`
open class RibBridgePresenter: Presentable {

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

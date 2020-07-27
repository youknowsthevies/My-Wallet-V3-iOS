//
//  RoutingAction.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 7/20/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public enum RoutingAction<A> {
    case next(A)
    case previous
    case dismiss
}

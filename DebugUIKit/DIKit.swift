//
//  DIKit.swift
//  DebugUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 23/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit

extension DependencyContainer {
    
    public static var debugUIKit = module {
        #if DEBUG_MENU
        factory(tag: DebugScreenContext.tag) { DebugCoordinator() as DebugCoordinating }
        #endif
    }
}

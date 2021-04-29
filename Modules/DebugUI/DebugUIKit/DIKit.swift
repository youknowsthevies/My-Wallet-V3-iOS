// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

extension DependencyContainer {
    
    public static var debugUIKit = module {
        #if INTERNAL_BUILD
        factory(tag: DebugScreenContext.tag) { DebugCoordinator() as DebugCoordinating }
        #endif
    }
}

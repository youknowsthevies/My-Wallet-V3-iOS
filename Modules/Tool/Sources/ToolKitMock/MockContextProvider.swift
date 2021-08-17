// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import JavaScriptCore
import ToolKit

class MockContextProvider: JSContextProviderAPI {
    var underlyingContext: JSContext!

    func fetchJSContext() -> JSContext {
        underlyingContext
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

class MockUserDefaults: UserDefaults {

    convenience init() {
        self.init(suiteName: "MockUserDefaults")!
    }

    override init?(suiteName suitename: String?) {
        super.init(suiteName: suitename)
        super.removePersistentDomain(forName: suitename!)
    }
}

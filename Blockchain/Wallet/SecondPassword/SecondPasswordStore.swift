// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

protocol SecondPasswordStorable: AnyObject {
    var secondPassword: Atomic<String?> { get }
}

final class SecondPasswordStore: SecondPasswordStorable {
    let secondPassword: Atomic<String?> = .init(nil)

    init() {
        NotificationCenter.when(.logout) { [weak self] _ in
            self?.secondPassword.mutate { $0 = nil }
        }
    }
}

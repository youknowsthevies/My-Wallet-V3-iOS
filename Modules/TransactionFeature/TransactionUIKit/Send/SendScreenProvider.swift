// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import UIKit

public protocol SendScreenProvider: AnyObject {
    func send(_ cryptoCurrency: CryptoCurrency) -> UIViewController
}

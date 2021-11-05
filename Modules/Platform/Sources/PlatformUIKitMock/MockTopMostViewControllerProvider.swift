// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import UIKit

public final class MockTopMostViewControllerProvider: TopMostViewControllerProviding {
    public var topMostViewController: UIViewController? {
        UIViewController()
    }
}

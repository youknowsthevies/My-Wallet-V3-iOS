// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public protocol TabSwapping: AnyObject {
    func send(from account: BlockchainAccount)
    func switchToSend()
    func switchTabToSwap()
    func switchTabToReceive()
    func switchToActivity()
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public protocol TabSwapping: AnyObject {
    func send(from account: BlockchainAccount)
    func receive(into account: BlockchainAccount)
    func withdraw(from account: BlockchainAccount)
    func deposit(into account: BlockchainAccount)
    func interestTransfer(into account: BlockchainAccount)
    func interestWithdraw(from account: BlockchainAccount)
    func switchToSend()
    func switchTabToSwap()
    func switchTabToReceive()
    func switchToActivity()
    func switchToActivity(for currencyType: CurrencyType)
}

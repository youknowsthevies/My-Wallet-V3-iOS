// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs
import ToolKit
import UIKit

final class SwapRootInteractor: Interactor, TransactionFlowListener {

    override init() {}

    func presentKYCFlowIfNeeded(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        unimplemented()
    }

    func dismissTransactionFlow() {
        unimplemented()
    }
}

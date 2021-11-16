// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RIBs
import UIKit

final class SignFlowInteractor: Interactor {

    var listener: SignFlowListening?
    weak var router: SignFlowRouting?
}

extension SignFlowInteractor: TransactionFlowListener {

    func presentKYCFlowIfNeeded(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        listener?.presentKYCFlow(from: viewController, completion: completion)
    }

    func dismissTransactionFlow() {
        listener?.signFlowDidComplete(with: .abandoned)
    }
}

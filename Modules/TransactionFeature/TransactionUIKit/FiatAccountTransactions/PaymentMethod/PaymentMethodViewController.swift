// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs
import RxSwift
import ToolKit

final class PaymentMethodViewController: UIViewController, PaymentMethodViewControllable {

    weak var listener: PaymentMethodListener?
    
    // MARK: - Init

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        unimplemented()
    }
}

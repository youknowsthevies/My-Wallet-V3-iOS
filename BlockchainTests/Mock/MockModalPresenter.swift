// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import Blockchain

final class MockModalPresenter: ModalPresenterAPI {
    var closeAllModalsCalled = false
    func closeAllModals() {
        closeAllModalsCalled = true
    }

    var closeModalCalled = false
    func closeModal(withTransition transition: String) {
        closeModalCalled = true
    }

    var showModalCalled = false
    func showModal(withContent content: UIView,
                   closeType: ModalCloseType,
                   showHeader: Bool,
                   headerText: String,
                   onDismiss: OnModalDismissed?,
                   onResume: OnModalResumed?) {
        showModalCalled = true
    }
}

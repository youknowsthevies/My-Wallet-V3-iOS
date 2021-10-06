// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import SwiftUI
import ToolKit

struct InterestAccountDetailsView: UIViewControllerRepresentable {

    typealias UIViewControllerType = InterestAccountDetailsViewController

    private let account: BlockchainAccount

    init(account: BlockchainAccount) {
        self.account = account
    }

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<InterestAccountDetailsView>
    ) -> InterestAccountDetailsViewController {
        let interactor = InterestAccountDetailsScreenInteractor(account: account)
        let presenter = InterestAccountDetailsScreenPresenter(interactor: interactor)
        let controller = InterestAccountDetailsViewController(presenter: presenter)
        return controller
    }

    func updateUIViewController(_ uiViewController: InterestAccountDetailsViewController, context: Context) {
        // noop
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI
import UIKit

public final class InterestAccountListHostingController: UIViewController {

    private let contentView: UIHostingController<InterestAccountListView>

    public init() {
        contentView = UIHostingController(
            rootView: InterestAccountListView(
                store: .init(
                    initialState: InterestAccountListState(
                        interestAccountDetails: .init(uniqueElements: []),
                        loadingInterestAccountList: true
                    ),
                    reducer: interestAccountListReducer,
                    environment: InterestAccountSelectionEnvironment.default
                )
            )
        )
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(contentView.view)
        addChild(contentView)
        setupConstraints()
    }

    private func setupConstraints() {
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.view.fillSuperview()
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import SwiftUI
import UIKit

public protocol SupportViewHostingControllerDelegate: AnyObject {
    // TODO:
}

public final class SupportViewHostingController: UIViewController, SupportViewHostingControllerDelegate {

    public weak var delegate: SupportViewHostingControllerDelegate?

    private let contentView: UIHostingController<SupportView>

    public init() {
        contentView = UIHostingController(
            rootView: SupportView(
                store: .init(
                    initialState: .init(isSupportViewSheetShown: true),
                    reducer: supportViewReducer,
                    environment: SupportViewEnvironment.default
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

    // MARK: - SupportViewHostingControllerDelegate
    // TODO:
}

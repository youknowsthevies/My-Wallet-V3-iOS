// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
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
                    environment: Void()
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
        NSLayoutConstraint.activate([
            contentView.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            contentView.view.heightAnchor.constraint(equalTo: view.heightAnchor),
            contentView.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.view.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - SupportViewHostingControllerDelegate
    // TODO:
}

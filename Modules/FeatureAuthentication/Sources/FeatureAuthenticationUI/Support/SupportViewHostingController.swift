// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import SwiftUI
import UIKit

public final class SupportViewHostingController: UIViewController, SupportViewViewDelegate {

    private let contentView: UIHostingController<SupportView>

    public init() {
        contentView = UIHostingController(
            rootView: SupportView(
                store: .init(
                    initialState: .init(
                        applicationVersion: Bundle.applicationVersion ?? "",
                        bundleIdentifier: Bundle.main.bundleIdentifier ?? ""
                    ),
                    reducer: supportViewReducer,
                    environment: .default
                )
            )
        )
        super.init(nibName: nil, bundle: nil)
        contentView.rootView.delegate = self
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
            contentView.view.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.view.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // MARK: - SupportViewViewDelegate

    func didTapContactUs() {
        guard let url = URL(string: "https://support.blockchain.com/hc/en-us/requests/new") else { return }
        dismiss(animated: true) {
            UIApplication.shared.open(
                url,
                options: [.universalLinksOnly: false],
                completionHandler: nil
            )
        }
    }

    func didTapViewFAQs() {
        let link = "https://support.blockchain.com/hc/en-us/categories/4416659837460-Wallet"
        guard let url = URL(string: link) else { return }
        dismiss(animated: true) {
            UIApplication.shared.open(
                url,
                options: [.universalLinksOnly: false],
                completionHandler: nil
            )
        }
    }
}

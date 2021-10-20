// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import SwiftUI
import UIComponentsKit
import UIKit

final class PortfolioEmptyStateTableViewCell: UITableViewCell {

    // MARK: - Private Properties

    private let title: UILabel = .init()
    private let subtitle: UILabel = .init()
    private let cta: ButtonView = .init()
    private let presenter: PortfolioEmptyStatePresenter = .init()
    private var minimalDoubleButton: UIHostingController<MinimalDoubleButton>!

    // MARK: - Setup

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    private func setup() {
        minimalDoubleButton = UIHostingController(
            rootView: MinimalDoubleButton(
                leftImage: .local(name: "Icon-qr", bundle: .platformUIKit),
                leftTitle: "Receive",
                leftAction: { [presenter] in
                    presenter.didTapReceive.accept(())
                },
                rightImage: .local(name: "icon-bank", bundle: .platformUIKit),
                rightTitle: "Deposit",
                rightAction: { [presenter] in
                    presenter.didTapDeposit.accept(())
                }
            )
        )

        title.numberOfLines = 0
        subtitle.numberOfLines = 0
        title.content = presenter.title
        subtitle.content = presenter.subtitle
        cta.viewModel = presenter.cta
        let button: UIView! = minimalDoubleButton.view

        contentView.addSubview(title)
        contentView.addSubview(subtitle)
        contentView.addSubview(cta)
        contentView.addSubview(button)

        title.layoutToSuperview(axis: .horizontal, offset: 24)
        subtitle.layoutToSuperview(axis: .horizontal, offset: 24)
        cta.layoutToSuperview(axis: .horizontal, offset: 24)
        button.layoutToSuperview(axis: .horizontal, offset: 24)

        title.layoutToSuperview(.top, offset: 70)
        title.layout(dimension: .height, to: 32)
        title.layout(edge: .bottom, to: .top, of: subtitle)
        subtitle.layout(edge: .bottom, to: .top, of: cta, offset: -24)
        cta.layout(dimension: .height, to: 48)
        cta.layout(edge: .bottom, to: .top, of: button, offset: -16)
        button.layoutToSuperview(.centerX)
        button.layoutToSuperview(.bottom, offset: 24)
    }
}

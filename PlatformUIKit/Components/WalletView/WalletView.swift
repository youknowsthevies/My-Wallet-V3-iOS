//
//  WalletView.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 2/22/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxSwift

/// `WalletView` shows the wallet's label, balance (in crypto), and
/// a `BadgeImageView` showing the currency. This is typically used as a
/// subview in a `UITableViewCell` for when the user needs to select
/// a wallet for a specific action (e.g. `send`).
final class WalletView: UIView {
    
    let badgeImageView = BadgeImageView()
    let nameLabel = UILabel()
    let balanceLabel = UILabel()
    let stackView = UIStackView()
    
    // MARK: - Injected
    
    public var viewModel: WalletViewViewModel! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let viewModel = viewModel else { return }
            badgeImageView.viewModel = viewModel.badgeImageViewModel
            nameLabel.content = viewModel.nameLabelContent
            viewModel
                .balanceLabelContent
                .drive(balanceLabel.rx.content)
                .disposed(by: disposeBag)
        }
    }
    
    private var disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    private func setup() {
        addSubview(badgeImageView)
        addSubview(stackView)
        [nameLabel, balanceLabel].forEach { [stackView] label in
            stackView.addArrangedSubview(label)
        }
        
        stackView.axis = .vertical
        stackView.spacing = 4.0
        stackView.distribution = .fill
        
        badgeImageView.layout(size: .edge(32.0))
        badgeImageView.layout(to: .centerY, of: self)
        badgeImageView.layoutToSuperview(.leading, .top, .bottom)
        badgeImageView.layout(edge: .trailing, to: .leading, of: stackView, offset: -16.0)
        stackView.layout(to: .centerY, of: self)
    }
}

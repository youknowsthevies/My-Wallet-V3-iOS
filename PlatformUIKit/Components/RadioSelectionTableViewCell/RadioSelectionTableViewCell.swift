//
//  RadioSelectionTableViewCell.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 2/19/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxSwift

/// A `UITableViewCell` with a radio button as its accessory view.
/// This radio button serves as a its selection state.
/// The `RadioSelectionTableViewCell` can contain any subview on the left but
/// will always show a `RadioButton` on the right.
public final class RadioSelectionTableViewCell: UITableViewCell {
    
    // MARK: - Public Properties
    
    public var presenter: RadioSelectionCellPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let presenter = presenter else { return }
            
            presenter
                .image
                .drive(radioView.rx.image)
                .disposed(by: disposeBag)
            
            switch presenter.content {
            case .wallet(let viewModel):
                walletView.viewModel = viewModel
            }
        }
    }
    
    // MARK: - Private Properties

    private var disposeBag = DisposeBag()
    private let walletView = WalletView()
    private let radioView = UIImageView()
    private let separatorView = UIView()

    // MARK: - Lifecycle

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }

    func setup() {
        contentView.addSubview(walletView)
        contentView.addSubview(radioView)
        contentView.addSubview(separatorView)
        separatorView.layoutToSuperview(.leading, .trailing, .bottom)
        separatorView.layout(dimension: .height, to: 1.0)
        separatorView.backgroundColor = .lightBorder
        walletView.layout(to: .centerY, of: contentView)
        walletView.layoutToSuperview(.top, offset: 16.0)
        walletView.layoutToSuperview(.leading, offset: 24.0)
        walletView.layout(edge: .trailing, to: .leading, of: radioView, offset: -16.0)
        radioView.layout(size: .edge(24.0))
        radioView.layout(to: .centerY, of: contentView)
        radioView.layoutToSuperview(.trailing, offset: -24.0)
    }
}

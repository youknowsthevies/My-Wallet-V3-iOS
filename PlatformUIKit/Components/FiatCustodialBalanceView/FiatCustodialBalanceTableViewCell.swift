//
//  FiatCustodialBalanceTableViewCell.swift
//  PlatformUIKit
//
//  Created by Daniel on 25/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public final class FiatCustodialBalanceTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    public var presenter: FiatCustodialBalanceViewPresenter! {
        didSet {
            custodialBalanceView.presenter = presenter
        }
    }

    private let custodialBalanceView: FiatCustodialBalanceView
    
    // MARK: - Lifecycle
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        custodialBalanceView = FiatCustodialBalanceView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(custodialBalanceView)
        custodialBalanceView.fillSuperview()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }
}

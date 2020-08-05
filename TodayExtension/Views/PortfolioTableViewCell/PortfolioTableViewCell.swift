//
//  PortfolioTableViewCell.swift
//  TodayExtension
//
//  Created by Alex McGregor on 7/2/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

final class PortfolioTableViewCell: UITableViewCell {
    
    // MARK: - Public Properties
    
    var presenter: PortfolioCellPresenter! {
        didSet {
            if let presenter = presenter {
                balanceLabel.content = presenter.balanceContent
                deltaLabel.content = presenter.deltaContent
            }
        }
    }
    
    // MARK: - Private Properties
    
    private let balanceLabel = UILabel()
    private let deltaLabel = UILabel()
    private let stackView = UIStackView()
    
    // MARK: - Lifecycle
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        selectionStyle = .none
        contentView.addSubview(stackView)
        backgroundColor = .clear
        stackView.layout(to: .leading, of: contentView, offset: 10.0)
        stackView.layout(dimension: .height, to: 60.0, priority: .defaultLow)
        stackView.addArrangedSubview(balanceLabel)
        stackView.addArrangedSubview(deltaLabel)
        
        stackView.distribution = .fillProportionally
        stackView.alignment = .leading
        stackView.axis = .vertical
        stackView.spacing = 4
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }
}

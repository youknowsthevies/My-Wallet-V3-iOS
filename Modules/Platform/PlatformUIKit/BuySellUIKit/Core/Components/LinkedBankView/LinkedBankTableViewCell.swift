// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

public final class LinkedBankTableViewCell: UITableViewCell {
    
    // MARK: - Public Properites
    
    public var viewModel: LinkedBankViewModelAPI! {
        didSet {
            linkedBankView.viewModel = viewModel
        }
    }
    
    // MARK: - Private Properties
    
    private let linkedBankView = LinkedBankView()
    
    // MARK: - Setup
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(linkedBankView)
        linkedBankView.fillSuperview()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
}


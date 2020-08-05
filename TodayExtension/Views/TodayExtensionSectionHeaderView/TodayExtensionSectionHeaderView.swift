//
//  TodayExtensionSectionHeaderView.swift
//  TodayExtension
//
//  Created by Alex McGregor on 7/2/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

final class TodayExtensionSectionHeaderView: UITableViewHeaderFooterView {
    
    var viewModel: TodayExtensionSectionHeaderViewModel! {
        didSet {
            titleLabel.content = viewModel.titleLabelContent
        }
    }
    
    private let titleLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        contentView.addSubview(titleLabel)
        contentView.backgroundColor = UIColor.TodayExtension.background
        titleLabel.layout(dimension: .height, to: 10.0, priority: .defaultLow)
        titleLabel.layoutToSuperview(.leading, offset: 10.0)
        titleLabel.layout(to: .top, of: contentView, offset: 16.0)
        titleLabel.layout(to: .bottom, of: contentView, offset: -8.0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }
}

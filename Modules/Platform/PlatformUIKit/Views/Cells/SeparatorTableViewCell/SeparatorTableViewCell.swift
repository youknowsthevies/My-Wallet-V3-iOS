//
//  SeparatorTableViewCell.swift
//  PlatformUIKit
//
//  Created by AlexM on 1/28/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

/// A simple cell displaying a single 1pt line with `0` padding.
public final class SeparatorTableViewCell: UITableViewCell {
    
    // MARK: - Private IBOutlets
    
    private let lineView = UIView()
    
    // MARK: - Setup
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        selectionStyle = .none
        contentView.addSubview(lineView)
        lineView.fillSuperview()
        lineView.layout(dimension: .height, to: 1)
        lineView.layoutToSuperview(.centerY)
        lineView.backgroundColor = .background
    }
}

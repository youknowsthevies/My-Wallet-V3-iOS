//
//  SelectionButtonTableViewCell.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 31/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public final class SelectionButtonTableViewCell: UITableViewCell {
    
    // MARK: - Injected
    
    public var viewModel: SelectionButtonViewModel! {
        didSet {
            selectionButtonView.viewModel = viewModel
        }
    }
    
    // MARK: - UI Properties
    
    private let selectionButtonView = SelectionButtonView()
    
    // MARK: - Setup
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(selectionButtonView)
        selectionButtonView.layout(dimension: .height, to: 48)
        selectionButtonView.layoutToSuperview(axis: .horizontal, offset: 24)
        selectionButtonView.layoutToSuperview(axis: .vertical, offset: 8)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }
}

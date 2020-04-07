//
//  TextFieldTableViewCell.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 17/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public final class TextFieldTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    private let textFieldView = TextFieldView()
    
    // MARK: - Lifecycle
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(textFieldView)
        textFieldView.layoutToSuperview(axis: .horizontal, offset: 24)
        textFieldView.layoutToSuperview(axis: .vertical)
        textFieldView.layout(dimension: .height, to: 48, priority: .defaultLow)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    public func setup(viewModel: TextFieldViewModel,
                      keyboardInteractionController: KeyboardInteractionController) {
        textFieldView.setup(
            viewModel: viewModel,
            keyboardInteractionController: keyboardInteractionController
        )
    }
}

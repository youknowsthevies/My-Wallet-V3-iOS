//
//  LabelTableViewCell.swift
//  PlatformUIKit
//
//  Created by AlexM on 1/27/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public final class LabelTableViewCell: UITableViewCell {
    
    // MARK: - Injected
    
    public var content: LabelContent! {
        didSet {
            descriptionLabel.content = content
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet private var descriptionLabel: UILabel!
}

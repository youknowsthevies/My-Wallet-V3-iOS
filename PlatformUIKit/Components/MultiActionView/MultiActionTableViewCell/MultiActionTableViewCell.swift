//
//  MultiActionTableViewCell.swift
//  Blockchain
//
//  Created by AlexM on 11/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

public final class MultiActionTableViewCell: UITableViewCell {
    
    public var presenter: MultiActionViewPresenting! {
        didSet {
            multiActionView.presenter = presenter
        }
    }
    
    @IBOutlet private var multiActionView: MultiActionView!
    
    // MARK: - Lifecycle
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }
}

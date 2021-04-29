// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

final class AirdropTypeTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var disclosureImageView: UIImageView!
    
    var presenter: AirdropTypeCellPresenter! {
        didSet {
            guard let presenter = presenter else { return }
            iconImageView.set(presenter.image)
            titleLabel.content = presenter.title
            descriptionLabel.content = presenter.description
        }
    }
    
    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }
}

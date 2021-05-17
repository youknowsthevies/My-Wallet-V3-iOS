// Copyright © Blockchain Luxembourg S.A. All rights reserved.

final class AirdropStatusTableViewCell: UITableViewCell {

    // MARK: - Injected

    var presenter: AirdropStatusCellPresenter! {
        didSet {
            guard let presenter = presenter else { return }
            titleLabel.content = presenter.title
            valueLabel.content = presenter.value
        }
    }

    // MARK: - IBOutlet Properties

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }
}

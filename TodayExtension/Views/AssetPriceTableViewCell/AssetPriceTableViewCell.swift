// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift

final class AssetPriceTableViewCell: UITableViewCell {

    // MARK: - Public Properties

    var presenter: AssetPriceCellPresenter! {
        didSet {
            disposeBag = DisposeBag()
            if let presenter = presenter {
                titleLabel.content = presenter.titleLabelContent
                descriptionLabel.content = presenter.descriptionLabelContent
                assetPriceView.presenter = presenter.priceViewPresenter
            } else {
                assetPriceView.presenter = nil
            }
        }
    }

    // MARK: - Private IBOutlets

    @IBOutlet private var assetPriceView: TodayAssetPriceView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var dividerView: UIView!

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        dividerView.backgroundColor = .textFieldText
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }
}

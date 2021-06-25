// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

final class AccountAuxiliaryView: UIView {

    // MARK: - Public Properties

    public var presenter: AccountAuxiliaryViewPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            presenter
                .titleLabel
                .drive(titleLabel.rx.content)
                .disposed(by: disposeBag)

            presenter
                .subtitleLabel
                .drive(subtitleLabel.rx.content)
                .disposed(by: disposeBag)

            presenter
                .badgeImageViewModel
                .drive(badgeImageView.rx.viewModel)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Private Properties

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let stackView = UIStackView()
    private let tapGestureRecognizer = UITapGestureRecognizer()
    private let badgeImageView = BadgeImageView()
    private var disposeBag = DisposeBag()

    public init() {
        super.init(frame: UIScreen.main.bounds)

        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        addSubview(badgeImageView)

        badgeImageView.layoutToSuperview(.centerY)
        badgeImageView.layoutToSuperview(.leading, offset: Spacing.outer)

        stackView.layoutToSuperview(.centerY)
        stackView.layout(edge: .leading, to: .trailing, of: badgeImageView, offset: Spacing.inner)

        stackView.axis = .vertical
        stackView.spacing = 4.0
    }

    required init?(coder: NSCoder) { unimplemented() }
}

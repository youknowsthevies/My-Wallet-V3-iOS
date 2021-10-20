// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public final class CheckboxTableViewCell: UITableViewCell {

    // MARK: - Public Properties

    public var viewModel: CheckboxViewModel! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let viewModel = viewModel else { return }

            viewModel
                .labelContent
                .drive(label.rx.content)
                .disposed(by: disposeBag)

            viewModel
                .image
                .drive(checkboxImageView.rx.image)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()
    private let label = UILabel()
    private let checkboxImageView = UIImageView()
    private let button = UIButton()

    // MARK: - Lifecycle

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }

    private func setup() {
        selectionStyle = .none
        contentView.addSubview(checkboxImageView)
        contentView.addSubview(label)
        contentView.addSubview(button)
        checkboxImageView.layout(size: .edge(16.0))
        checkboxImageView.layout(edges: .leading, to: contentView, offset: 24)
        checkboxImageView.layout(edges: .top, to: contentView, offset: 24)
        label.layout(edges: .top, to: checkboxImageView)
        label.layout(edge: .leading, to: .trailing, of: checkboxImageView, offset: 8.0)
        label.layout(edge: .trailing, to: .trailing, of: contentView, offset: -24)
        label.layout(edge: .bottom, to: .bottom, of: contentView, offset: -16)
        label.numberOfLines = 0

        button.fillSuperview()
        button.addTarget(self, action: #selector(toggled(sender:)), for: .touchUpInside)
    }

    @objc func toggled(sender: UIButton) {
        viewModel.selectedRelay.accept(!viewModel.selectedRelay.value)
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import Localization
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit
import UIComponentsKit

final class ReceiveScreenViewController: BaseScreenViewController {
    private typealias LocalizedString = LocalizationConstants.Receive

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let nameLabel = UILabel()
    private let balanceLabel = UILabel()
    private let assetImageView = BadgeImageView()
    private let thumbImageView = UIImageView()

    private let qrCodeImageView = UIImageView()

    private let domainHeaderLabel = UILabel()
    private let domainSeparator = UIView()
    private let domainLabel = UILabel()
    private let addressHeaderLabel = UILabel()
    private let addressSeparator = UIView()
    private let addressLabel = UILabel()
    private let memoHeaderLabel = UILabel()
    private let memoSeparator = UIView()
    private let memoLabel = UILabel()
    private let memoNoteContainer = UIView()
    private let memoNoteTextView = InteractableTextView()
    private let copyButton = ButtonView()
    private let shareButton = ButtonView()

    private var memoNoteContainerToLabelConstraint: NSLayoutConstraint!
    private var memoNoteContainerHeightConstraint: NSLayoutConstraint!
    private var memoLabelToSeparatorConstraint: NSLayoutConstraint!
    private var memoHeaderToAddressLabelConstraint: NSLayoutConstraint!
    private var memoHeaderHeightConstraint: NSLayoutConstraint!
    private var copyButtonToMemoNoteConstraint: NSLayoutConstraint!
    private var contentSizeObserver: NSKeyValueObservation?

    private var copyButtonTopOffset: CGFloat {
        switch DevicePresenter.type {
        case .superCompact:
            return 16
        case .compact,
             .regular,
             .max:
            return 48
        }
    }

    private let presenter: ReceiveScreenPresenter
    private let disposeBag = DisposeBag()

    init(presenter: ReceiveScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        unimplemented()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupPresenter()

        // Prevent unecessary rendering
        displayMemo(show: false)
    }

    private func setupPresenter() {
        domainHeaderLabel.content = presenter.walletDomainLabelContent

        addressHeaderLabel.content = presenter.walletAddressLabelContent

        memoHeaderLabel.content = presenter.memoLabelContent

        presenter.domainLabelContentPresenting
            .state
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .loaded(next: let content):
                    if !content.labelContent.isEmpty {
                        self?.domainLabel.isHidden = false
                        self?.domainSeparator.isHidden = false
                        self?.domainHeaderLabel.isHidden = false
                        self?.domainLabel.content = content.labelContent
                    }
                case .loading:
                    self?.domainLabel.text = nil
                }
            })
            .disposed(by: disposeBag)

        presenter.addressLabelContentPresenting
            .state
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .loaded(next: let content):

                    self?.addressLabel.content = content.labelContent
                case .loading:
                    self?.addressLabel.text = nil
                }
            })
            .disposed(by: disposeBag)

        presenter.memoLabelContentPresenting
            .state
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .loaded(next: let content):
                    self?.displayMemo(show: !content.labelContent.text.isEmpty)
                    self?.memoLabel.content = content.labelContent
                case .loading:
                    self?.memoLabel.text = nil
                }
            })
            .disposed(by: disposeBag)

        presenter.balanceLabelContentPresenting
            .state
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .loaded(next: let content):
                    self?.balanceLabel.content = content.labelContent
                case .loading:
                    self?.balanceLabel.text = nil
                }
            })
            .disposed(by: disposeBag)

        presenter.nameLabelContentPresenting
            .state
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .loaded(next: let content):
                    self?.nameLabel.content = content.labelContent
                case .loading:
                    self?.nameLabel.text = nil
                }
            })
            .disposed(by: disposeBag)

        presenter.qrCode
            .drive(qrCodeImageView.rx.image)
            .disposed(by: disposeBag)

        copyButton.viewModel = presenter.copyButton
        shareButton.viewModel = presenter.shareButton

        presenter.assetImage
            .drive(assetImageView.rx.viewModel)
            .disposed(by: disposeBag)
    }

    private func displayMemo(show: Bool) {
        memoNoteContainer.isHidden = !show
        memoLabel.isHidden = !show
        memoSeparator.isHidden = !show
        memoHeaderLabel.isHidden = !show
        memoNoteContainerToLabelConstraint.constant = show ? 16 : 0
        memoNoteContainerHeightConstraint.isActive = !show
        memoLabelToSeparatorConstraint.constant = show ? 16 : 0
        memoHeaderToAddressLabelConstraint.constant = show ? 16 : 0
        memoHeaderHeightConstraint.isActive = !show
        copyButtonToMemoNoteConstraint.constant = show ? 16 : copyButtonTopOffset
    }

    private func setupNavigationBar() {
        set(
            barStyle: .darkContent(),
            leadingButtonStyle: .none,
            trailingButtonStyle: .close
        )
        titleViewStyle = .text(value: presenter.title)
    }

    private func setupView() {
        view.backgroundColor = .white

        // MARK: Add Subviews

        view.addSubview(scrollView)

        // MARK: Scroll View

        scrollView.layoutToSuperview(.leading, .trailing, .top, .bottom, usesSafeAreaLayoutGuide: true)
        scrollView.addSubview(contentView)

        // MARK: Content View

        contentView.layoutToSuperview(.leading, .trailing, .top, .bottom, .width)
        contentView.layoutToSuperview(.height, relation: .greaterThanOrEqual)
        contentView.addSubview(nameLabel)
        contentView.addSubview(balanceLabel)
        contentView.addSubview(thumbImageView)
        contentView.addSubview(assetImageView)
        contentView.addSubview(qrCodeImageView)
        contentView.addSubview(domainHeaderLabel)
        contentView.addSubview(domainSeparator)
        contentView.addSubview(domainLabel)
        contentView.addSubview(addressHeaderLabel)
        contentView.addSubview(addressSeparator)
        contentView.addSubview(addressLabel)
        contentView.addSubview(memoHeaderLabel)
        contentView.addSubview(memoSeparator)
        contentView.addSubview(memoLabel)
        contentView.addSubview(memoNoteContainer)
        contentView.addSubview(copyButton)
        contentView.addSubview(shareButton)

        // MARK: Wallet Name

        nameLabel.layoutToSuperview(.top, offset: 9)
        nameLabel.layoutToSuperview(.leading, offset: 24)
        nameLabel.layout(dimension: .height, to: 24)

        // MARK: Wallet Balance

        balanceLabel.layout(edge: .top, to: .bottom, of: nameLabel)
        balanceLabel.layoutToSuperview(.leading, offset: 24)
        balanceLabel.layout(dimension: .height, to: 21)

        // MARK: Receive Icon Image

        thumbImageView.layout(dimension: .width, to: 24)
        thumbImageView.layout(dimension: .height, to: 24)
        thumbImageView.layoutToSuperview(.trailing, offset: -24)
        thumbImageView.layoutToSuperview(.top, offset: 20)
        thumbImageView.set(
            ImageViewContent(imageResource: ImageAsset.iconReceiveGray.imageResource)
        )

        // MARK: Asset Image

        assetImageView.layout(dimension: .width, to: 32)
        assetImageView.layout(dimension: .height, to: 32)
        assetImageView.layout(edge: .centerY, to: .centerY, of: thumbImageView)
        assetImageView.layout(edge: .trailing, to: .leading, of: thumbImageView, offset: 4)

        // MARK: Share Button

        shareButton.layout(dimension: .height, to: 48)
        shareButton.layoutToSuperview(axis: .horizontal, offset: 24)
        shareButton.layoutToSuperview(.bottom, usesSafeAreaLayoutGuide: true, offset: -16)
        shareButton.layout(edge: .top, to: .bottom, of: copyButton, offset: 16)

        // MARK: Copy Button

        copyButton.layout(dimension: .height, to: 48)
        copyButton.layoutToSuperview(axis: .horizontal, offset: 24)
        copyButtonToMemoNoteConstraint = copyButton.layout(edge: .top, to: .bottom, of: memoNoteContainer, offset: copyButtonTopOffset)

        // MARK: Memo Note Container

        memoNoteContainer.backgroundColor = .mediumBackground
        memoNoteContainer.layer.cornerRadius = 8
        memoNoteContainer.layoutToSuperview(axis: .horizontal, offset: 24)
        memoNoteContainerToLabelConstraint = memoNoteContainer.layout(edge: .top, to: .bottom, of: memoLabel, offset: 16)
        memoNoteContainerHeightConstraint = memoNoteContainer.layout(dimension: .height, to: 0, activate: false)
        memoNoteContainer.addSubview(memoNoteTextView)

        // MARK: Memo Note

        memoNoteTextView.viewModel = presenter.memoNoteViewModel
        memoNoteTextView.backgroundColor = .clear
        memoNoteTextView.layoutToSuperview(axis: .horizontal, offset: 12)
        memoNoteTextView.layoutToSuperview(axis: .vertical, offset: 12)

        // MARK: Memo Label

        memoLabel.layoutToSuperview(axis: .horizontal, offset: 24)
        memoLabelToSeparatorConstraint = memoLabel.layout(edge: .top, to: .bottom, of: memoSeparator, offset: 16)
        memoLabel.numberOfLines = 0

        // MARK: Memo Separator

        memoSeparator.backgroundColor = .lightBorder
        memoSeparator.layout(dimension: .height, to: 1)
        memoSeparator.layout(edge: .leading, to: .trailing, of: memoHeaderLabel, offset: 8)
        memoSeparator.layoutToSuperview(.trailing)
        memoSeparator.layout(edge: .bottom, to: .lastBaseline, of: memoHeaderLabel)

        // MARK: Memo Header

        memoHeaderLabel.layoutToSuperview(.leading, offset: 24)
        memoHeaderToAddressLabelConstraint = memoHeaderLabel.layout(edge: .top, to: .bottom, of: addressLabel, offset: 16)
        memoHeaderHeightConstraint = memoHeaderLabel.layout(dimension: .height, to: 0, activate: false)

        // MARK: Domain Label

        domainLabel.isHidden = true
        domainLabel.layoutToSuperview(axis: .horizontal, offset: 24)
        domainLabel.layout(edge: .top, to: .bottom, of: domainSeparator, offset: 16)
        domainLabel.numberOfLines = 0

        // MARK: Domain Separator

        domainSeparator.isHidden = true
        domainSeparator.backgroundColor = .lightBorder
        domainSeparator.layout(dimension: .height, to: 1)
        domainSeparator.layout(edge: .leading, to: .trailing, of: domainHeaderLabel, offset: 8)
        domainSeparator.layoutToSuperview(.trailing)
        domainSeparator.layout(edge: .bottom, to: .lastBaseline, of: domainHeaderLabel)
        domainSeparator.bottomAnchor.constraint(equalTo: addressHeaderLabel.topAnchor, constant: -50).isActive = true

        // MARK: Domain Header

        domainHeaderLabel.isHidden = true
        domainHeaderLabel.layoutToSuperview(.leading, offset: 24)

        // MARK: Address Label

        addressLabel.layoutToSuperview(axis: .horizontal, offset: 24)
        addressLabel.layout(edge: .top, to: .bottom, of: addressSeparator, offset: 16)
        addressLabel.numberOfLines = 0

        // MARK: Address Separator

        addressSeparator.backgroundColor = .lightBorder
        addressSeparator.layout(dimension: .height, to: 1)
        addressSeparator.layout(edge: .leading, to: .trailing, of: addressHeaderLabel, offset: 8)
        addressSeparator.layoutToSuperview(.trailing)
        addressSeparator.layout(edge: .bottom, to: .lastBaseline, of: addressHeaderLabel)

        // MARK: Address Header

        addressHeaderLabel.layoutToSuperview(.leading, offset: 24)

        // MARK: QRCode ImageView

        qrCodeImageView.layout(dimension: .width, to: 200)
        qrCodeImageView.layout(dimension: .height, to: 200)
        qrCodeImageView.layoutToSuperview(.centerX)
        qrCodeImageView.contentMode = .scaleAspectFit

        // MARK: UILayoutGuide for QRCodeImageView

        let topGuide = UILayoutGuide()
        let bottomGuide = UILayoutGuide()
        contentView.addLayoutGuide(topGuide)
        contentView.addLayoutGuide(bottomGuide)
        NSLayoutConstraint.activate([
            topGuide.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 16),
            topGuide.bottomAnchor.constraint(equalTo: qrCodeImageView.topAnchor),
            bottomGuide.topAnchor.constraint(equalTo: qrCodeImageView.bottomAnchor),
            bottomGuide.bottomAnchor.constraint(equalTo: addressHeaderLabel.topAnchor, constant: -16),
            topGuide.heightAnchor.constraint(equalTo: bottomGuide.heightAnchor)
        ])
        contentSizeObserver = scrollView.observe(\.contentSize) { scrollView, _ in
            scrollView.isScrollEnabled = scrollView.contentSize.height > scrollView.frame.height
        }
    }
}

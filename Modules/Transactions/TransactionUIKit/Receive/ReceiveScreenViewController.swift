//
//  ReceiveScreenViewController.swift
//  TransactionUIKit
//
//  Created by Paulo on 21/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Localization
import PlatformUIKit
import RxCocoa
import RxSwift
import TransactionKit
import ToolKit

final class ReceiveScreenViewController: BaseScreenViewController {
    private typealias LocalizedString = LocalizationConstants.Receive

    private let nameLabel: UILabel = UILabel()
    private let balanceLabel: UILabel = UILabel()
    private let assetImageView: UIImageView = UIImageView()
    private let thumbImageView: UIImageView = UIImageView()

    private let qrCodeImageView: UIImageView = UIImageView()

    private let walletHeaderLabel: UILabel = UILabel()
    private let separator: UIView = UIView()
    private let addressLabel: UILabel = UILabel()
    private let copyButton: ButtonView = ButtonView()
    private let shareButton: ButtonView = ButtonView()

    private let presenter: ReceiveScreenPresenter
    private let disposeBag: DisposeBag = DisposeBag()

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
    }

    private func setupPresenter() {
        walletHeaderLabel.content = presenter.walletAddressLabelContent

        presenter.addressLabelContentPresenting
            .state
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .loaded(next: let content):
                    self?.addressLabel.content = content.labelContent
                case .loading:
                    self?.addressLabel.text = nil
                }
            })
            .disposed(by: disposeBag)
        
        presenter.balanceLabelContentPresenting
            .state
            .observeOn(MainScheduler.asyncInstance)
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
            .observeOn(MainScheduler.asyncInstance)
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
            .drive(assetImageView.rx.image)
            .disposed(by: disposeBag)
    }

    private func setupNavigationBar() {
        set(barStyle: .darkContent(),
            leadingButtonStyle: .none,
            trailingButtonStyle: .close)
        titleViewStyle = .text(value: presenter.title)
    }

    private func setupView() {
        view.backgroundColor = .white
        
        // MARK: Add Subviews
        view.addSubview(nameLabel)
        view.addSubview(balanceLabel)
        view.addSubview(thumbImageView)
        view.addSubview(assetImageView)
        view.addSubview(qrCodeImageView)
        view.addSubview(walletHeaderLabel)
        view.addSubview(separator)
        view.addSubview(addressLabel)
        view.addSubview(copyButton)
        view.addSubview(shareButton)

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
        thumbImageView.image = ImageAsset.iconReceiveGray.image

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
        let copyButtonTopOffset: CGFloat
        switch DevicePresenter.type {
        case .superCompact:
            copyButtonTopOffset = 16
        case .compact,
             .regular,
             .max:
            copyButtonTopOffset = 48
        }
        copyButton.layout(edge: .top, to: .bottom, of: addressLabel, offset: copyButtonTopOffset)

        // MARK: Address Label
        addressLabel.layoutToSuperview(axis: .horizontal, offset: 24)
        addressLabel.layout(edge: .top, to: .bottom, of: separator, offset: 16)
        addressLabel.numberOfLines = 0

        // MARK: Separator
        separator.backgroundColor = .lightBorder
        separator.layout(dimension: .height, to: 1)
        separator.layout(edge: .leading, to: .trailing, of: walletHeaderLabel, offset: 8)
        separator.layoutToSuperview(.trailing)
        separator.layout(edge: .bottom, to: .lastBaseline, of: walletHeaderLabel)

        // MARK: Wallet Address Header
        walletHeaderLabel.layoutToSuperview(.leading, offset: 24)

        // MARK: QRCode ImageView
        qrCodeImageView.layout(dimension: .width, to: 200)
        qrCodeImageView.layout(dimension: .height, to: 200)
        qrCodeImageView.layoutToSuperview(.centerX)
        qrCodeImageView.contentMode = .scaleAspectFit

        // MARK: UILayoutGuide for QRCodeImageView
        let topGuide = UILayoutGuide()
        let bottomGuide = UILayoutGuide()
        view.addLayoutGuide(topGuide)
        view.addLayoutGuide(bottomGuide)
        NSLayoutConstraint.activate([
            topGuide.topAnchor.constraint(equalTo: view.topAnchor, constant: 64),
            topGuide.bottomAnchor.constraint(equalTo: qrCodeImageView.topAnchor),
            bottomGuide.topAnchor.constraint(equalTo: qrCodeImageView.bottomAnchor),
            bottomGuide.bottomAnchor.constraint(equalTo: separator.topAnchor, constant: 15),
            topGuide.heightAnchor.constraint(equalTo: bottomGuide.heightAnchor)
        ])
    }
}

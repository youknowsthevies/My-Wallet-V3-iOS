// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

/// A QR Code view shown in Addresses Screen.
@objc final class AddressesQRCodeView: UIView {

    private let header: UILabel = .init(frame: .zero)
    private let footer: UILabel = .init(frame: .zero)
    private let copied: UILabel = .init(frame: .zero)
    private let qrCode: UIImageView = .init(frame: .zero)
    private var address: String?

    @objc override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(header)
        header.layout(edges: .top, to: self, offset: 24)
        header.layout(edges: .leading, to: self, offset: 24)
        header.layout(edges: .trailing, to: self, offset: -24)
        header.numberOfLines = 0
        header.textAlignment = .center

        addSubview(qrCode)
        qrCode.layout(size: .edge(190))
        qrCode.layout(edges: .centerX, to: self)
        qrCode.layout(edge: .top, to: .bottom, of: header, offset: 24)

        addSubview(footer)
        footer.layout(edge: .top, to: .bottom, of: qrCode, offset: 24)
        footer.layout(edges: .leading, to: self, offset: 24)
        footer.layout(edges: .trailing, to: self, offset: -24)
        footer.numberOfLines = 0
        footer.textAlignment = .center

        addSubview(copied)
        copied.layout(edge: .top, to: .bottom, of: qrCode, offset: 24)
        copied.layout(edges: .leading, to: self, offset: 24)
        copied.layout(edges: .trailing, to: self, offset: -24)
        copied.numberOfLines = 0
        copied.textAlignment = .center
        copied.content = .init(
            text: "✓ " + LocalizationConstants.Receive.Text.copiedToClipboard,
            font: .main(.regular, 18),
            color: .green,
            alignment: .center,
            accessibility: .none
        )
        copied.alpha = 0

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCopy))
        footer.addGestureRecognizer(tap)
        footer.isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) { nil }

    @objc func configure(address: String, header: String, copyButton: String) {
        self.address = address
        let qrCode = QRCode(string: address)
        self.header.content = .init(
            text: header,
            font: .main(.regular, 18),
            color: .textFieldText,
            alignment: .center,
            accessibility: .none
        )
        self.qrCode.image = qrCode?.image
        footer.content = .init(
            text: copyButton,
            font: .main(.regular, 18),
            color: .textFieldText,
            alignment: .center,
            accessibility: .none
        )
    }

    @objc private func didTapCopy() {
        UIPasteboard.general.string = address
        animateCopy()
    }

    private func animateCopy() {
        footer.isUserInteractionEnabled = false
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.footer.alpha = 0
                self?.copied.alpha = 1
            },
            completion: { [weak self] _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [weak self] in
                    UIView.animate(
                        withDuration: 0.2,
                        animations: { [weak self] in
                            self?.footer.alpha = 1
                            self?.copied.alpha = 0
                        }, completion: { [weak self] _ in
                            self?.footer.isUserInteractionEnabled = true
                        }
                    )
                }
            }
        )
    }
}

//
//  PrimaryButtonContainer.swift
//  PlatformUIKit
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxRelay
import RxSwift
import UIKit

@IBDesignable
public class PrimaryButtonContainer: NibBasedView {

    private struct FontNames {
        static let montserratRegular = "Montserrat-Regular"
        static let montserratMedium = "Montserrat-Medium"
    }

    public enum PrimaryButtonFont: Int {
        case kyc = 0
        case send = 1
        case small = 2

        var font: UIFont {
            switch self {
            case .kyc:
                return UIFont(
                    name: FontNames.montserratMedium,
                    size: 20.0
                    ) ?? UIFont.systemFont(ofSize: 20, weight: .medium)
            case .send:
                return UIFont(
                    name: FontNames.montserratRegular,
                    size: 17.0
                    ) ?? UIFont.systemFont(ofSize: 17.0, weight: .regular)
            case .small:
                return UIFont(
                    name: FontNames.montserratRegular,
                    size: 14.0
                ) ?? UIFont.systemFont(ofSize: 14.0, weight: .regular)
            }
        }
    }

    // MARK: Private IBOutlets

    @IBOutlet fileprivate var activityIndicator: UIActivityIndicatorView!
    @IBOutlet fileprivate var primaryButton: UIButton!

    // MARK: Public

    /// Simple block for handling the call back when the
    /// `primaryButton` is tapped.
    public var actionBlock: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        primaryButton.layer.cornerRadius = 4.0
        primaryButton.accessibilityIdentifier = Accessibility.Identifier.General.mainCTAButton
    }

    public var activityIndicatorStyle: UIActivityIndicatorView.Style = .whiteLarge {
        didSet {
            activityIndicator.style = activityIndicatorStyle
        }
    }

    // MARK: IBInspectable

    @IBInspectable public var primaryButtonFont: Int = 0 {
        didSet {
            let value = PrimaryButtonFont(rawValue: primaryButtonFont) ?? .kyc
            primaryButton.titleLabel?.font = value.font
        }
    }

    @IBInspectable public var buttonBackgroundColor: UIColor = UIColor.brandSecondary {
        didSet {
            primaryButton.backgroundColor = buttonBackgroundColor
        }
    }

    @IBInspectable public var buttonTitleColor: UIColor = UIColor.white {
        didSet {
            primaryButton.setTitleColor(buttonTitleColor, for: .normal)
        }
    }

    @IBInspectable public var disabledButtonBackgroundColor: UIColor = UIColor.brandSecondary

    @IBInspectable public var isLoading: Bool = false {
        didSet {
            isLoading == true ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
            isLoading == true ? primaryButton.setTitle(nil, for: .normal) : primaryButton.setTitle(title, for: .normal)
        }
    }

    @IBInspectable public var title: String = "" {
        didSet {
            primaryButton.setTitle(title, for: .normal)
        }
    }

    @IBInspectable public var attributedTitle: NSAttributedString = NSAttributedString(string: "") {
        didSet {
            primaryButton.setAttributedTitle(attributedTitle, for: .normal)
        }
    }

    @IBInspectable public var isEnabled: Bool = true {
        didSet {
            primaryButton.isEnabled = isEnabled
            primaryButton.backgroundColor = isEnabled ? buttonBackgroundColor : disabledButtonBackgroundColor
        }
    }

    // MARK: Actions

    @IBAction func primaryButtonTapped(_ sender: UIButton) {
        if let block = actionBlock {
            block()
        }
    }
}

extension Reactive where Base: PrimaryButtonContainer {
    public var isEnabled: Binder<Bool> {
        Binder(base) { container, isEnabled in
            container.isEnabled = isEnabled
        }
    }
}

extension Reactive where Base: PrimaryButtonContainer {
    public var tap: ControlEvent<Void> {
        base.primaryButton.rx.tap
    }
}

//
//  BCNavigationController.swift
//  Blockchain
//
//  Created by Paulo on 29/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

class BCNavigationController: UINavigationController {

    enum Appearance: Int {
        case light
        case dark
    }

    private let topBar = UIView(frame: .zero)
    let backButton = UIButton(type: .custom)
    let closeButton = UIButton(frame: .zero)
    private let headerLabel = UILabel(frame: .zero)

    var headerTitle: String? {
        set {
            headerLabel.text = newValue
        }
        get {
            headerLabel.text
        }
    }

    init(rootViewController: UIViewController, title: String? = nil) {
        super.init(rootViewController:rootViewController)
        self.headerTitle = title
    }

    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    // NOTE: Don't delete this - that fixes a crash that occurs when subclassing a UINavigationController
    // on iOS 12.
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let safeAreaInsets: UIEdgeInsets = UIApplication.shared.keyWindow?.rootViewController?.view.safeAreaInsets ?? .zero

        let defaultStyle = Screen.Style.Bar.lightContent()

        let topBarHeight: CGFloat = ConstantsObjcBridge.defaultNavigationBarHeight() + safeAreaInsets.top
        topBar.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: topBarHeight)
        topBar.backgroundColor = defaultStyle.backgroundColor
        view.addSubview(topBar)

        headerLabel.frame = CGRect(x: 60, y: safeAreaInsets.top + 6, width: 200, height: 30)
        headerLabel.font = defaultStyle.titleFont
        headerLabel.textColor = defaultStyle.titleColor
        headerLabel.textAlignment = .center
        headerLabel.adjustsFontSizeToFitWidth = true
        headerLabel.text = headerTitle
        headerLabel.accessibilityIdentifier = AccessibilityIdentifiers.Navigation.titleLabel
        headerLabel.center = CGPoint(x: topBar.center.x, y: headerLabel.center.y)
        
        topBar.addSubview(headerLabel)

        closeButton.frame = CGRect(x: view.frame.size.width - 80, y: 15, width: 80, height: 51)
        closeButton.imageEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 18)
        closeButton.contentHorizontalAlignment = .right

        let closeImage: UIImage = UIImage(named: "close")!.withRenderingMode(.alwaysTemplate)
        closeButton.setImage(closeImage, for: .normal)
        closeButton.center = CGPoint(x: closeButton.center.x, y: headerLabel.center.y)
        closeButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        closeButton.tintColor = .white
        closeButton.accessibilityIdentifier = AccessibilityIdentifiers.Navigation.closeButton
        topBar.addSubview(closeButton)

        backButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 0)
        backButton.frame = CGRect(x: 0, y: 0, width: 85, height: 51)
        backButton.center = CGPoint(x: backButton.center.x, y: headerLabel.center.y)
        backButton.contentHorizontalAlignment = .left
        backButton.setTitle("", for: .normal)

        let backImage: UIImage = UIImage(named: "back_chevron_icon")!.withRenderingMode(.alwaysTemplate)
        backButton.setImage(backImage, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        backButton.accessibilityIdentifier = AccessibilityIdentifiers.Navigation.backButton
        topBar.addSubview(backButton)
    }

    func apply(appearance: Appearance, backgroundColor: UIColor) {
        let tintColor: UIColor = appearance == .dark ? .white : .brandPrimary

        self.backButton.tintColor = tintColor
        self.closeButton.tintColor = tintColor
        self.headerLabel.textColor = tintColor
        self.backButton.tintColor = tintColor
        self.topBar.backgroundColor = backgroundColor
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if viewControllers.count > 1 {
            backButton.isHidden = false
            closeButton.isHidden = true
        } else {
            backButton.isHidden = true
            closeButton.isHidden = false
        }
    }

    @objc private func closeButtonAction() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func backButtonAction() {
        if viewControllers.count > 1 {
            popViewController(animated: true)
        } else {
            closeButtonAction()
        }
    }
}

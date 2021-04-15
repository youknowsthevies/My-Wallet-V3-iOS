//
//  NavigationBarButtonItem.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 08/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

class NavigationBarButtonItem: UIBarButtonItem {

    // MARK: - Types

    enum ItemType {
        case processing
        case content(content: Screen.NavigationBarContent, tap: () -> Void)
        case none
    }

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(type: ItemType, color: UIColor) {
        super.init()

        tintColor = color
        target = self
        style = .plain

        switch type {
        case .content(content: let content, tap: let tap):
            let font = UIFont.main(.medium, 16)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: color
            ]
            setTitleTextAttributes(attributes, for: .normal)
            setTitleTextAttributes(attributes, for: .highlighted)
            setTitleTextAttributes(attributes, for: .disabled)
            title = content.title
            image = content.image
            accessibilityIdentifier = content.accessibility?.id.rawValue
            rx.tap
                .bind { tap() }
                .disposed(by: disposeBag)
        case .processing:
            let activityIndicator = UIActivityIndicatorView(style: .white)
            customView = activityIndicator
            activityIndicator.startAnimating()
        case .none:
            break
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { nil }
}

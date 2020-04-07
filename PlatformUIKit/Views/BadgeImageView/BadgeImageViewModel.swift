//
//  BadgeImageViewModel.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 3/24/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

public struct BadgeImageViewModel {
    
    // MARK: - Types
    
    public struct Theme {
        public let backgroundColor: UIColor
        public let contentColor: UIColor?
        public let imageName: String
        
        public init(backgroundColor: UIColor,
                    contentColor: UIColor? = nil,
                    imageName: String) {
            self.backgroundColor = backgroundColor
            self.contentColor = contentColor
            self.imageName = imageName
                //contentColor != nil ? image.withRenderingMode(.alwaysTemplate) : image
        }
    }
    
    // MARK: - Properties
    
    /// The theme of the view
    public var theme: Theme {
        set {
            backgroundColorRelay.accept(newValue.backgroundColor)
            contentColorRelay.accept(newValue.contentColor)
            imageNameRelay.accept(newValue.imageName)
        }
        get {
            return Theme(backgroundColor: backgroundColorRelay.value,
                         contentColor: contentColorRelay.value,
                         imageName: imageNameRelay.value)
        }
    }
    
    /// Corner radius
    public let cornerRadius: CGFloat
    
    /// The background color relay
    public let backgroundColorRelay = BehaviorRelay<UIColor>(value: .clear)
    
    /// The background color of the badge
    public var backgroundColor: Driver<UIColor> {
        return backgroundColorRelay.asDriver()
    }
    
    /// The content color relay
    public let contentColorRelay = BehaviorRelay<UIColor?>(value: nil)
    
    /// The content color of the title
    public var contentColor: Driver<UIColor?> {
        return contentColorRelay.asDriver()
    }
    
    /// The image name relay
    public let imageNameRelay = BehaviorRelay<String>(value: "")
    
    /// Image to be displayed on the badge
    public var image: Driver<UIImage> {
        let imageObservable =  imageNameRelay
            .compactMap { UIImage(named: $0) }
        return Observable
            .combineLatest(
                imageObservable,
                contentColorRelay
            )
            .map { (image, color) in
                color != nil ? image.withRenderingMode(.alwaysTemplate) : image
            }
            .asDriver(onErrorJustReturn: .init())
    }
    
    /// - parameter cornerRadius: corner radius of the component
    public init(cornerRadius: CGFloat = 4) {
        self.cornerRadius = cornerRadius
    }
}

extension BadgeImageViewModel {
    
    /// Returns a default badge with an image. It uses the standard
    /// `background` color and does not apply a tintColor to the image.
    /// It has rounded corners.
    public static func `default`(
        with imageName: String
        ) -> BadgeImageViewModel {
        var viewModel = BadgeImageViewModel()
        viewModel.theme = Theme(
            backgroundColor: .background,
            imageName: imageName
        )
        return viewModel
    }
    
    /// Returns a primary badge with an image. It uses the standard
    /// `defaultBadge` color for the content
    ///  and applies a `lightBadgeBackground` to the background.
    /// It has rounded corners, though you can apply a `cornerRadius`
    public static func primary(
        with imageName: String,
        contentColor: UIColor = .defaultBadge,
        backgroundColor: UIColor = .lightBadgeBackground,
        cornerRadius: CGFloat = 8
        ) -> BadgeImageViewModel {
        var viewModel = BadgeImageViewModel(
            cornerRadius: cornerRadius
        )
        viewModel.theme = Theme(
            backgroundColor: backgroundColor,
            imageName: imageName
        )
        return viewModel
    }
}

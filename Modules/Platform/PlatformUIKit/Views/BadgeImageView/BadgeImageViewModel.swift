// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import UIKit

public struct BadgeImageViewModel {

    // MARK: - Types

    public struct Theme {
        public let backgroundColor: UIColor
        public let imageViewContent: ImageViewContent

        public init(
            backgroundColor: UIColor,
            imageViewContent: ImageViewContent
        ) {
            self.backgroundColor = backgroundColor
            self.imageViewContent = imageViewContent
        }
    }

    public enum SizingType {
        case configuredByOwner
        case constant(CGSize)
    }

    public enum CornerRadius {
        case round
        case value(CGFloat)
    }

    // MARK: - Properties

    /// Corner radius
    public let cornerRadiusRelay = BehaviorRelay<CornerRadius>(value: .value(8))

    /// Image to be displayed on the badge
    public var cornerRadius: Driver<CornerRadius> {
        cornerRadiusRelay.asDriver()
    }

    /// The background color relay
    public let backgroundColorRelay = BehaviorRelay<UIColor>(value: .clear)

    /// The background color of the badge
    public var backgroundColor: Driver<UIColor> {
        backgroundColorRelay.asDriver()
    }

    public let marginOffsetRelay = BehaviorRelay<CGFloat>(value: 4)
    public var marginOffset: Driver<CGFloat> {
        marginOffsetRelay.asDriver()
    }

    public let sizingTypeRelay = BehaviorRelay<SizingType>(value: .configuredByOwner)
    public var sizingType: Driver<SizingType> {
        sizingTypeRelay.asDriver()
    }

    /// The image name relay
    public let imageContentRelay = BehaviorRelay<ImageViewContent>(value: .empty)

    /// Image to be displayed on the badge
    public var imageContent: Driver<ImageViewContent> {
        imageContentRelay.asDriver()
    }

    /// - parameter cornerRadius: corner radius of the component
    public init(cornerRadius: CornerRadius = .value(4)) {
        cornerRadiusRelay.accept(cornerRadius)
    }

    func set(theme: Theme) {
        backgroundColorRelay.accept(theme.backgroundColor)
        imageContentRelay.accept(theme.imageViewContent)
    }
}

// MARK: - Factory

extension BadgeImageViewModel {

    private typealias AccessibilityId = Accessibility.Identifier.BadgeImageView

    public static var empty: BadgeImageViewModel {
        BadgeImageViewModel()
    }

    /// Returns a default badge with an image.
    ///
    /// It uses the standard `background` color and does not apply a tintColor to the image.
    /// It has rounded corners.
    public static func `default`(
        image: ImageResource?,
        cornerRadius: CornerRadius = .value(8),
        accessibilityIdSuffix: String
    ) -> BadgeImageViewModel {
        let viewModel = BadgeImageViewModel(cornerRadius: cornerRadius)
        viewModel.set(
            theme: Theme(
                backgroundColor: .background,
                imageViewContent: ImageViewContent(
                    imageResource: image,
                    accessibility: .id("\(AccessibilityId.prefix)\(accessibilityIdSuffix)"),
                    renderingMode: .normal
                )
            )
        )
        return viewModel
    }

    public static func template(
        image: ImageResource,
        templateColor: UIColor,
        backgroundColor: UIColor,
        cornerRadius: CornerRadius = .round,
        accessibilityIdSuffix: String
    ) -> BadgeImageViewModel {
        let viewModel = BadgeImageViewModel(cornerRadius: cornerRadius)
        viewModel.set(
            theme: Theme(
                backgroundColor: backgroundColor,
                imageViewContent: ImageViewContent(
                    imageResource: image,
                    accessibility: .id("\(AccessibilityId.prefix)\(accessibilityIdSuffix)"),
                    renderingMode: .template(templateColor)
                )
            )
        )
        return viewModel
    }

    /// Returns a primary badge with an image.
    ///
    /// It uses the standard `defaultBadge` color for the content and applies a `lightBadgeBackground` to the background.
    /// It has rounded corners, though you can apply a `cornerRadius`
    public static func primary(
        image: ImageResource,
        contentColor: UIColor = .defaultBadge,
        backgroundColor: UIColor = .lightBadgeBackground,
        cornerRadius: CornerRadius = .value(8),
        accessibilityIdSuffix: String
    ) -> BadgeImageViewModel {
        let viewModel = BadgeImageViewModel(cornerRadius: cornerRadius)
        viewModel.set(
            theme: Theme(
                backgroundColor: backgroundColor,
                imageViewContent: ImageViewContent(
                    imageResource: image,
                    accessibility: .id("\(AccessibilityId.prefix)\(accessibilityIdSuffix)"),
                    renderingMode: .template(contentColor)
                )
            )
        )
        return viewModel
    }
}

extension BadgeImageViewModel: Equatable {
    public static func == (lhs: BadgeImageViewModel, rhs: BadgeImageViewModel) -> Bool {
        lhs.imageContentRelay.value == rhs.imageContentRelay.value
    }
}

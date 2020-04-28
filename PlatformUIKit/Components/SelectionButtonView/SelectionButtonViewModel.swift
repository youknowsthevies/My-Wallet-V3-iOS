//
//  SelectionButtonViewModel.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 22/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa

/// A view model for selection-view to use throughout the app
public final class SelectionButtonViewModel {

    // MARK: - Types

    public struct AccessibilityContent {
        public let id: String
        public let label: String
        
        fileprivate static var empty: AccessibilityContent {
            return AccessibilityContent(id: "", label: "")
        }

        fileprivate var accessibility: Accessibility {
            Accessibility(
                id: .value(id),
                label: .value(label),
                traits: .value(.button),
                isAccessible: !id.isEmpty
            )
        }
        
        public init(id: String, label: String) {
            self.id = id
            self.label = label
        }
    }
    
    public enum LeadingContent {
        case badgeImage(BadgeImageViewModel)
        case label(LabelContent)
        case none
    }
    
    public enum LeadingContentType {
        public struct Image {
            let name: String
            let background: Color
            let cornerRadius: BadgeImageViewModel.CornerRadius
            let offset: CGFloat
            let size: CGSize
            
            public init(name: String,
                        background: Color,
                        offset: CGFloat = 4,
                        cornerRadius: BadgeImageViewModel.CornerRadius,
                        size: CGSize) {
                self.name = name
                self.background = background
                self.offset = offset
                self.cornerRadius = cornerRadius
                self.size = size
            }
        }
        
        case image(Image)
        case text(String)
    }

    private typealias AccessibilityId = Accessibility.Identifier.SelectionButtonView

    // MARK: - Public Properties

    /// Title Relay: title describing the selection
    public let titleRelay = BehaviorRelay<String>(value: "")

    /// Subtitle Relay:  The subtitle describing the selection
    ///
    /// A  nil value represents the inexistence of a subtitle, in which case a view may react to this by changing its layout.
    public let subtitleRelay = BehaviorRelay<String?>(value: "")

    /// Image Name Relay:  A `String` for image asset name.
    public let leadingContentTypeRelay = BehaviorRelay<LeadingContentType?>(value: nil)

    /// The leading content's size
    public var leadingImageViewSize: Driver<CGSize> {
        leadingContentTypeRelay
            .asDriver()
            .map { type in
                switch type {
                case .image(let image):
                    return image.size
                case .text, .none:
                    return CGSize(edge: 1)
                }
            }
    }
    
    /// Accessibility content relay
    public let accessibilityContentRelay = BehaviorRelay<AccessibilityContent>(value: .empty)
    
    /// Trailing image content relay
    public let trailingImageViewContentRelay = BehaviorRelay<ImageViewContent>(value: .empty)
    
    /// Title Relay: title describing the selection
    public let shouldShowSeparatorRelay = BehaviorRelay(value: false)
    
    /// Horizontal offset relay
    public let horizontalOffsetRelay = BehaviorRelay<CGFloat>(value: 24)
    
    /// Vertical offset relay
    public let verticalOffsetRelay = BehaviorRelay<CGFloat>(value: 16)
    
    /// Allows any component to observe taps
    public var tap: Signal<Void> {
        tapRelay.asSignal()
    }
    
    // MARK: - Internal Properties

    /// A tap relay that accepts taps on the button
    let tapRelay = PublishRelay<Void>()

    /// The horizontal offset of the content
    var horizontalOffset: Driver<CGFloat> {
        horizontalOffsetRelay.asDriver()
    }
    
    /// The vertical offset of the content
    var verticalOffset: Driver<CGFloat> {
        verticalOffsetRelay.asDriver()
    }
    
    /// Streams the leading image
    var shouldShowSeparator: Driver<Bool> {
        shouldShowSeparatorRelay.asDriver()
    }
    
    /// Streams the leading content
    var leadingContent: Driver<LeadingContent> {
        leadingContentRelay.asDriver()
    }

    /// Streams the title
    var title: Driver<LabelContent> {
        titleRelay
            .map {
                LabelContent(
                    text: $0,
                    font: .mainSemibold(16),
                    color: .titleText,
                    accessibility: .id(AccessibilityId.label)
                )
            }
            .asDriver(onErrorJustReturn: .empty)
    }

    /// Streams the title
    var subtitle: Driver<LabelContent?> {
        subtitleRelay
            .map {
                guard let subtitle = $0
                    else { return nil }
                return LabelContent(
                    text: subtitle,
                    font: .mainMedium(14),
                    color: .descriptionText,
                    accessibility: .id(AccessibilityId.label)
                )
            }
            .asDriver(onErrorJustReturn: LabelContent.empty)
    }

    /// Streams the trailing image
    var trailingImageViewContent: Driver<ImageViewContent> {
        trailingImageViewContentRelay.asDriver()
    }

    /// Streams the accessibility
    var accessibility: Driver<Accessibility> {
        accessibilityContentRelay
            .asDriver()
            .map { $0.accessibility }
    }

    // MARK: - Private Properties

    private let leadingContentRelay = BehaviorRelay<LeadingContent>(value: .none)
    private let disposeBag = DisposeBag()
    
    public init(showSeparator: Bool = false) {
        shouldShowSeparatorRelay.accept(showSeparator)
        
        leadingContentTypeRelay
            .map { type in
                switch type {
                case .image(let image):
                    let imageViewContent = ImageViewContent(
                        imageName: image.name,
                        bundle: .platformUIKit
                    )
                    let badgeViewModel = BadgeImageViewModel()
                    badgeViewModel.marginOffsetRelay.accept(image.offset)
                    badgeViewModel.cornerRadiusRelay.accept(image.cornerRadius)
                    badgeViewModel.set(
                        theme: .init(
                            backgroundColor: image.background,
                            imageViewContent: imageViewContent
                        )
                    )
                    return .badgeImage(badgeViewModel)
                case .text(let text):
                    return .label(
                        LabelContent(
                            text: text,
                            font: .mainMedium(30),
                            color: .black
                        )
                    )
                case .none:
                    return .none
                }
            }
            .bind(to: leadingContentRelay)
            .disposed(by: disposeBag)
    }
}

//
//  SelectionButtonViewModel.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 22/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxRelay
import RxSwift

/// A view model for selection-view to use throughout the app
public final class SelectionButtonViewModel: IdentifiableType {

    // MARK: - Types

    public struct AccessibilityContent {
        public let id: String
        public let label: String
        
        fileprivate static var empty: AccessibilityContent {
            AccessibilityContent(id: "", label: "")
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
    
    public enum TrailingContent {
        case transaction(TransactionDescriptorViewModel)
        case image(ImageViewContent)
        case empty
        
        var transaction: TransactionDescriptorViewModel? {
            switch self {
            case .transaction(let value):
                return value
            case .image, .empty:
                return nil
            }
        }
        
        var image: ImageViewContent? {
            switch self {
            case .image(let value):
                return value
            case .transaction, .empty:
                return nil
            }
        }
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

    public var identity: AnyHashable {
        titleRelay.value + (subtitleRelay.value ?? "")
    }

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
    
    /// Accessibility for the title
    public let titleAccessibilityRelay = BehaviorRelay<Accessibility>(value: .none)
    
    /// Accessibility for the subtitle
    public let subtitleAccessibilityRelay = BehaviorRelay<Accessibility>(value: .none)
    
    /// Accessibility content relay
    public let accessibilityContentRelay = BehaviorRelay<AccessibilityContent>(value: .empty)
    
    /// Trailing content relay
    public let trailingContentRelay = BehaviorRelay<TrailingContent>(value: .empty)
    
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
    
    /// Determines if the button accepts touches
    public let isButtonEnabledRelay = BehaviorRelay(value: true)
    var isButtonEnabled: Driver<Bool> {
        isButtonEnabledRelay.asDriver()
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
        Observable
            .combineLatest(
                titleRelay.asObservable(),
                titleAccessibilityRelay.asObservable()
            )
            .map {
                let title = $0.0
                let accessibility = $0.1
                return LabelContent(
                    text: title,
                    font: .main(.semibold, 16),
                    color: .titleText,
                    accessibility: accessibility
                )
            }
            .asDriver(onErrorJustReturn: .empty)
    }

    /// Streams the title
    var subtitle: Driver<LabelContent?> {
        Observable
            .combineLatest(
                subtitleRelay.asObservable(),
                subtitleAccessibilityRelay.asObservable()
            )
            .map {
                guard let subtitle = $0.0
                    else { return nil }
                let accessibility = $0.1
                return LabelContent(
                    text: subtitle,
                    font: .main(.medium, 14),
                    color: .descriptionText,
                    accessibility: accessibility
                )
            }
            .asDriver(onErrorJustReturn: LabelContent.empty)
    }
    
    /// Streams the trailing content
    var trailingContent: Driver<TrailingContent> {
        trailingContentRelay
            .asDriver()
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
                            font: .main(.medium, 30),
                            color: .black
                        )
                    )
                case .none:
                    return .none
                }
            }
            .bindAndCatch(to: leadingContentRelay)
            .disposed(by: disposeBag)
    }
}

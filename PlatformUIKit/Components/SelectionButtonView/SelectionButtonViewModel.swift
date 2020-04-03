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

    public enum LeadingContentType {
        case image(String)
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
    public let leadingContentRelay = BehaviorRelay<LeadingContentType?>(value: nil)

    /// Accessibility Label Relay : A `String` that stands for the button accessibility
    public let accessibilityLabelRelay = BehaviorRelay<String>(value: "")

    /// Allows any component to observe taps
    public var tap: Signal<Void> {
        tapRelay.asSignal()
    }

    /// Title Relay: title describing the selection
    public let shouldShowSeparatorRelay = BehaviorRelay<Bool>(value: false)

    // MARK: - Internal Properties

    /// A tap relay that accepts taps on the button
    let tapRelay = PublishRelay<Void>()

    /// Streams the leading image
    var shouldShowSeparator: Driver<Bool> {
        shouldShowSeparatorRelay.asDriver()
    }

    /// Streams the leading image
    var leadingContent: Driver<ViewContent> {
        leadingContentRelay
            .map {
                switch $0 {
                case .image(let name):
                    return .image(
                        ImageViewContent(
                            imageName: name,
                            accessibility: .id(AccessibilityId.image)
                        )
                    )
                case .text(let text):
                    return .label(
                        LabelContent(
                            text: text,
                            font: .mainMedium(30),
                            color: .black,
                            accessibility: .id(AccessibilityId.image)
                        )
                    )
                case .none:
                    return .none
                }
            }
            .asDriver(onErrorJustReturn: .none)
    }

    /// Streams the title
    var title: Driver<LabelContent> {
        titleRelay
            .map {
                LabelContent(
                    text: $0,
                    font: .mainMedium(16),
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

    /// Streams the disclosure image
    var disclosureImageViewContent: Driver<ImageViewContent> {
        disclosureImageViewContentRelay.asDriver()
    }

    /// Streams the accessibility
    var accessibility: Driver<Accessibility> {
        accessibilityLabelRelay
            .map {
                Accessibility(
                    id: .value(AccessibilityId.button),
                    label: .value($0),
                    traits: .value(.button)
                )
            }
            .asDriver(onErrorJustReturn: Accessibility())
    }

    // MARK: - Private Properties

    private let disclosureImageViewContentRelay = BehaviorRelay<ImageViewContent>(
        value: ImageViewContent(
            imageName: "icon-disclosure-down-small",
            accessibility: .id(AccessibilityId.disclosureImage)
        )
    )

    /// An empty initializer
    public init(showSeparator: Bool = false) {
        shouldShowSeparatorRelay.accept(showSeparator)
    }
}

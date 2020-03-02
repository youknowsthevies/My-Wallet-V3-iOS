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
    
    private typealias AccessibilityId = Accessibility.Identifier.SelectionButtonView
    
    // MARK: - Exposed Properties
    
    /// Allows any component to observe taps
    public var tap: Signal<Void> {
        tapRelay.asSignal()
    }
    
    /// A tap relay that accepts taps on the button
    let tapRelay = PublishRelay<Void>()
    
    /// Streams the leading image
    var leadingImage: Driver<ImageViewContent> {
        leadingImageRelay.asDriver()
    }
    
    /// Streams the title
    var title: Driver<LabelContent> {
        titleRelay.asDriver()
    }
    
    /// Streams the disclosure image
    var disclosureImageViewContent: Driver<ImageViewContent> {
        disclosureImageViewContentRelay.asDriver()
    }
    
    /// Streams the accessibility
    var accessibility: Driver<Accessibility> {
        accessibilityRelay.asDriver()
    }
        
    // MARK: - Private Properties
    
    private let accessibilityRelay = BehaviorRelay<Accessibility>(value: .none)
    private let leadingImageRelay = BehaviorRelay<ImageViewContent>(value: .empty)
    private let titleRelay = BehaviorRelay<LabelContent>(value: .empty)
    private let disclosureImageViewContentRelay = BehaviorRelay(
        value: ImageViewContent(
            imageName: "icon-disclosure-small",
            accessibility: .id(AccessibilityId.disclosureImage)
        )
    )
    
    /// Sets new selection properties
    ///
    /// - Parameter imageName: The name of the image
    /// - Parameter title: The title describing the selection
    /// - Parameter accessibilityLabel: A `String` that stands for the button accessibility.
    public func set(imageName: String, title: String, accessibilityLabel: String) {
        let imageContent = ImageViewContent(
            imageName: imageName,
            accessibility: .id(AccessibilityId.image)
        )
        let labelContent = LabelContent(
            text: title,
            font: .mainMedium(16),
            color: .titleText,
            accessibility: .id(AccessibilityId.label)
        )

        accessibilityRelay.accept(
            .init(
                id: .value(AccessibilityId.button),
                label: .value(accessibilityLabel),
                traits: .value(.button)
            )
        )
        leadingImageRelay.accept(imageContent)
        titleRelay.accept(labelContent)
    }
    
    /// An empty initializer
    public init() {}
}

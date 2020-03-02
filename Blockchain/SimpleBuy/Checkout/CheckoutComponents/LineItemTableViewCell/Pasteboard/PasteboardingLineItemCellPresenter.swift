//
//  PasteboardingLineItemCellPresenter.swift
//  Blockchain
//
//  Created by AlexM on 1/29/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import RxCocoa

protocol PasteboardLineItemPresenting: class {
    var tapRelay: PublishRelay<Void> { get }
    var pasteboardValue: String { get }
}

final class PasteboardingLineItemCellPresenter: LineItemCellPresenting, PasteboardLineItemPresenting {
    
    // MARK: - Input
    
    struct Input {
        let title: String
        let titleInteractionText: String
        let description: String
        let descriptionInteractionText: String
        let interactionDuration: Int
        
        init(title: String,
             titleInteractionText: String,
             description: String,
             descriptionInteractionText: String,
             interactionDuration: Int = 4) {
            self.title = title
            self.titleInteractionText = titleInteractionText
            self.description = description
            self.descriptionInteractionText = descriptionInteractionText
            self.interactionDuration = interactionDuration
        }
    }
    
    // MARK: - Types
    
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.Checkout.LineItem
    
    // MARK: - Properties
    
    let titleLabelContentPresenter: LabelContentPresenting
    let descriptionLabelContentPresenter: LabelContentPresenting
    
    /// The background color relay
    let backgroundColorRelay = BehaviorRelay<UIColor>(value: .clear)
    
    /// The background color of the button
    var backgroundColor: Driver<UIColor> {
        return backgroundColorRelay.asDriver()
    }
    
    var image: Driver<UIImage?> {
        return imageRelay.asDriver()
    }
    
    /// The background color relay
    let imageRelay = BehaviorRelay<UIImage?>(value: #imageLiteral(resourceName: "clipboard"))
    
    // MARK: - PasteboardLineItemPresenting
    
    /// Streams events when the component is being tapped
    let tapRelay = PublishRelay<Void>()
    let pasteboardValue: String
    
    // MARK: - Private Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    
    init(input: Input, pasteboard: Pasteboarding = UIPasteboard.general) {
        pasteboardValue = input.description
        
        let titleInteractor = PasteboardLabelContentInteractor(
            text: input.title,
            interactionText: input.titleInteractionText,
            interactionDuration: input.interactionDuration
        )
        
        let descriptionInteractor = PasteboardLabelContentInteractor(
            text: input.description,
            interactionText: input.descriptionInteractionText,
            interactionDuration: input.interactionDuration
        )
        
        titleLabelContentPresenter = PasteboardLabelContentPresenter(
            interactor: titleInteractor,
            descriptors: .lineItemTitle
        )
        descriptionLabelContentPresenter = PasteboardLabelContentPresenter(
            interactor: descriptionInteractor,
                descriptors: .lineItemDescription
        )
        
        tapRelay
            .bind(to: titleInteractor.pasteboardTriggerRelay)
            .disposed(by: disposeBag)
        
        tapRelay
            .bind(to: descriptionInteractor.pasteboardTriggerRelay)
            .disposed(by: disposeBag)
        
        tapRelay
            .bind {
                let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
                feedbackGenerator.prepare()
                feedbackGenerator.impactOccurred()
            }
            .disposed(by: disposeBag)
        
        tapRelay
            .map { "green-checkmark-bottom-sheet" }
            .map { UIImage(named: $0) }
            .bind(to: imageRelay)
            .disposed(by: disposeBag)
        
        tapRelay
            .map { .affirmativeBackground }
            .bind(to: backgroundColorRelay)
            .disposed(by: disposeBag)
        
        tapRelay
            .bind { pasteboard.string = input.description }
            .disposed(by: disposeBag)
        
        let delay = tapRelay
            .debounce(
                .seconds(input.interactionDuration),
                scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated)
            )
            .share(replay: 1)
                        
        delay
            .map { "clipboard" }
            .map { UIImage(named: $0) }
            .bind(to: imageRelay)
            .disposed(by: disposeBag)
            
        delay
            .map { .clear }
            .bind(to: backgroundColorRelay)
            .disposed(by: disposeBag)
    }
}

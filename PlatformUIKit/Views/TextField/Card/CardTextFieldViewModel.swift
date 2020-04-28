//
//  CardTextFieldViewModel.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 20/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit
import PlatformKit

public protocol CardTypeSource: class {
    var cardType: Observable<CardType> { get }
}

public final class CardTextFieldViewModel: TextFieldViewModel {
    
    // MARK: - Properties
    
    /// Streams the card thumbnail image view content. determined by the card type
    var cardThumbnailBadgeImageViewModel: Observable<BadgeImageViewModel?> {
        cardNumberValidator.cardType
            .distinctUntilChanged()
            .map { type in
                guard type.isKnown else { return nil }
                let content = ImageViewContent(
                    imageName: type.thumbnail,
                    accessibility: .id(type.name),
                    bundle: .platformUIKit
                )
                let viewModel = BadgeImageViewModel(cornerRadius: .value(4))
                viewModel.sizingTypeRelay.accept(.constant(CGSize(width: 32, height: 20)))
                viewModel.marginOffsetRelay.accept(0)
                viewModel.set(
                    theme: .init(
                        backgroundColor: .background,
                        imageViewContent: content
                    )
                )
                return viewModel
            }
    }
    
    private let cardNumberValidator: CardNumberValidator
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(validator: CardNumberValidator,
                hintDisplayType: HintDisplayType = .constant,
                messageRecorder: MessageRecording) {
        cardNumberValidator = validator
        super.init(
            with: .cardNumber,
            hintDisplayType: hintDisplayType,
            validator: validator,
            formatter: TextFormatterFactory.cardNumber,
            messageRecorder: messageRecorder
        )
        
        cardThumbnailBadgeImageViewModel
            .map { viewModel in
                if let viewModel = viewModel {
                    return .badge(viewModel)
                } else {
                    return .empty
                }
            }
            .bind(to: accessoryContentTypeRelay)
            .disposed(by: disposeBag)
    }
}

//
//  CardTextFieldViewModel.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 20/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

public protocol CardTypeSource: class {
    var cardType: Observable<CardType?> { get }
}

public final class CardTextFieldViewModel: TextFieldViewModel {
    
    // MARK: - Properties
    
    /// Streams the card thumbnail image view content. determined by the card type
    var cardThumbnailImageViewContent: Observable<ImageViewContent?> {
        cardNumberValidator.cardType
            .distinctUntilChanged()
            .map { type in
                guard let type = type else {
                    return nil
                }
                return ImageViewContent(
                    imageName: type.thumbnail,
                    accessibility: .id(type.name),
                    bundle: .platformUIKit
                )
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
        
        cardThumbnailImageViewContent
            .map { content in
                if let content = content {
                    return .image(content)
                } else {
                    return .empty
                }
            }
            .bind(to: accessoryContentTypeRelay)
            .disposed(by: disposeBag)
    }
}

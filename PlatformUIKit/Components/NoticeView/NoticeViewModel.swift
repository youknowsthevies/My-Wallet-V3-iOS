//
//  NoticeViewModel.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 28/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxRelay
import RxSwift

public struct NoticeViewModel: Equatable {
    
    public enum Alignement {
        case top
        case center
    }
    
    /// The image content
    public let imageViewContent: ImageViewContent
    
    /// The label content
    public let labelContents: [LabelContent]
    
    /// The vertical alignment of the element
    public let verticalAlignment: Alignement
    
    public init(imageViewContent: ImageViewContent,
                labelContents: [LabelContent],
                verticalAlignment: Alignement) {
        self.imageViewContent = imageViewContent
        self.labelContents = labelContents
        self.verticalAlignment = verticalAlignment
    }
    
    public init(imageViewContent: ImageViewContent,
                labelContents: LabelContent...,
                verticalAlignment: Alignement) {
        self.imageViewContent = imageViewContent
        self.labelContents = labelContents
        self.verticalAlignment = verticalAlignment
    }
}

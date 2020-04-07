//
//  NoticeViewModel.swift
//  Blockchain
//
//  Created by Daniel Huri on 28/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa

public struct NoticeViewModel: Equatable {
    
    public enum Alignement {
        case top
        case center
    }
    
    /// The image content
    let imageViewContent: ImageViewContent
    
    /// The label content
    let labelContent: LabelContent
    
    /// The vertical alignment of the element
    let verticalAlignment: Alignement
    
    public init(imageViewContent: ImageViewContent,
                labelContent: LabelContent,
                verticalAlignment: Alignement) {
        self.imageViewContent = imageViewContent
        self.labelContent = labelContent
        self.verticalAlignment = verticalAlignment
    }
}

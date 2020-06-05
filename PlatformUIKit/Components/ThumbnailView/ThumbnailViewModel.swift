//
//  ThumbnailViewPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 16/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit

public struct ThumbnailViewModel {
        
    // MARK: - Exposed Properties
    
    // MARK: - Private Properties
    
    let imageViewContent: ImageViewContent
    let backgroundColor: Color
    
    // MARK: - Setup
    
    public init(imageViewContent: ImageViewContent,
                backgroundColor: Color) {
        self.imageViewContent = imageViewContent
        self.backgroundColor = backgroundColor
    }
}

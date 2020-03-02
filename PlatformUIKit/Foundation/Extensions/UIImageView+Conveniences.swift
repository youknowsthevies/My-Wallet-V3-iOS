//
//  UIImageView+Conveniences.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 05/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa

public struct ImageViewContent {
    private let bundle: Bundle
    let imageName: String?
    let accessibility: Accessibility
    
    public var isEmpty: Bool {
        return imageName == nil
    }
    
    var image: UIImage? {
        guard let imageName = imageName else { return nil }
        return UIImage(named: imageName, in: bundle, compatibleWith: .none)
    }
        
    public static var empty: ImageViewContent {
        return .init()
    }
    
    public init(imageName: String? = nil,
                accessibility: Accessibility = .none,
                bundle: Bundle = .main) {
        self.imageName = imageName
        self.accessibility = accessibility
        self.bundle = bundle
    }
}

extension UIImageView {
    public func set(_ content: ImageViewContent) {
        image = content.image
        accessibility = content.accessibility
    }
}

extension Reactive where Base: UIImageView {
    public var content: Binder<ImageViewContent> {
        return Binder(base) { imageView, content in
            imageView.set(content)
        }
    }
}

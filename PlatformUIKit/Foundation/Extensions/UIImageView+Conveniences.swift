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
    
    public enum RenderingMode {
        case template(Color)
        case normal
        
        var templateColor: Color? {
            switch self {
            case .template(let color):
                return color
            case .normal:
                return nil
            }
        }
    }
    
    public static var empty: ImageViewContent {
        return .init()
    }
    
    public var isEmpty: Bool {
        return imageName == nil
    }
    
    var image: UIImage? {
        guard let imageName = imageName else { return nil }
        
        switch renderingMode {
        case .normal:
            return UIImage(named: imageName, in: bundle, compatibleWith: .none)
        case .template:
            let image = UIImage(named: imageName, in: bundle, compatibleWith: .none)
            return image?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    let imageName: String?
    let accessibility: Accessibility
    
    private let renderingMode: RenderingMode
    private let bundle: Bundle
    
    public init(imageName: String? = nil,
                accessibility: Accessibility = .none,
                renderingMode: RenderingMode = .normal,
                bundle: Bundle = .main) {
        self.imageName = imageName
        self.accessibility = accessibility
        self.renderingMode = renderingMode
        self.bundle = bundle
    }
}

extension ImageViewContent: Equatable {
    public static func == (lhs: ImageViewContent, rhs: ImageViewContent) -> Bool {
        return lhs.imageName == rhs.imageName &&
               lhs.accessibility == rhs.accessibility &&
               lhs.bundle.bundleIdentifier == rhs.bundle.bundleIdentifier
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

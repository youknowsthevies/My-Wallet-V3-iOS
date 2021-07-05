// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift

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
        .init()
    }

    public var isEmpty: Bool {
        imageResource == nil
    }

    var templateColor: UIColor? {
        renderingMode.templateColor
    }

    var image: UIImage? {
        switch imageResource {
        case .local(name: let imageName, bundle: let bundle):
            switch renderingMode {
            case .normal:
                return UIImage(named: imageName, in: bundle, compatibleWith: .none)
            case .template:
                let image = UIImage(named: imageName, in: bundle, compatibleWith: .none)
                return image?.withRenderingMode(.alwaysTemplate)
            }
        case .remote:
            // TODO: IOS-4958: Remote loaded resources.
            return nil
        case nil:
            return nil
        }
    }

    let accessibility: Accessibility
    private let imageResource: ImageResource?
    private let renderingMode: RenderingMode

    public init(imageResource: ImageResource? = nil,
                accessibility: Accessibility = .none,
                renderingMode: RenderingMode = .normal) {
        self.imageResource = imageResource
        self.accessibility = accessibility
        self.renderingMode = renderingMode
    }
}

extension ImageViewContent: Equatable {
    public static func == (lhs: ImageViewContent, rhs: ImageViewContent) -> Bool {
        lhs.imageResource == rhs.imageResource &&
               lhs.accessibility == rhs.accessibility
    }
}

extension UIImageView {
    public func set(_ content: ImageViewContent?) {
        image = content?.image
        tintColor = content?.templateColor
        accessibility = content?.accessibility ?? .none
    }
}

extension Reactive where Base: UIImageView {
    public var content: Binder<ImageViewContent> {
        Binder(base) { imageView, content in
            imageView.set(content)
        }
    }
}

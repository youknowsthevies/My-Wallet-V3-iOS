// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

extension UIImage {

    /// Places the image inset inside of a grey filled circle background
    var circled: UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor(.semantic.muted.opacity(0.10)).setFill()
            context.cgContext.fillEllipse(in: context.format.bounds)

            UIColor(.semantic.muted).setFill()
            draw(in: context.format.bounds.insetBy(dx: 4, dy: 4))
        }
        return image
    }

    /// Add padding to an image
    /// - Parameter padding: Padding for each edge
    /// - Returns: An image larger in size by the sum of the padding provided, with the source image offset inside accordingly.
    func padded(by padding: UIEdgeInsets) -> UIImage {
        let size = CGSize(
            width: size.width + padding.left + padding.right,
            height: size.height + padding.top + padding.bottom
        )
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            draw(in: context.format.bounds.inset(by: padding))
        }
        return image
    }
}

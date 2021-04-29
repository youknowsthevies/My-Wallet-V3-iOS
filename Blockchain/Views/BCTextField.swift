// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

class BCTextField: BCSecureTextField {

    override func awakeFromNib() {
        super.awakeFromNib()
        super.setupOnePixelLine()
    }

    override var frame: CGRect {
        didSet {
            super.setupOnePixelLine()
        }
    }
}

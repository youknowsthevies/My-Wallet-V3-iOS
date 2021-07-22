// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

@objc class BCSecureTextField: UITextField {

    init() {
        super.init(frame: CGRect.zero)
        autocorrectionType = .no
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        autocorrectionType = .no
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        autocorrectionType = .no
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        autocorrectionType = .no
    }

    @objc func setupOnePixelLine() {
        if superview == nil {
            return
        }

        let onePixelHeight = 1.0 / UIScreen.main.scale
        let onePixelLine = UIView(
            frame: CGRect(
                x: 0,
                y: frame.size.height - onePixelHeight,
                width: frame.size.width + 15,
                height: onePixelHeight
            )
        )
        onePixelLine.frame = superview!.convert(onePixelLine.frame, from: self)
        onePixelLine.isUserInteractionEnabled = false
        onePixelLine.backgroundColor = .gray2
        superview!.addSubview(onePixelLine)
    }
}

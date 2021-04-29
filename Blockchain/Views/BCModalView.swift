// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

extension BCModalView {
    @objc func createHeader() -> UILabel {
        let style = Screen.Style.Bar.lightContent()
        let label = UILabel(frame: .zero)
        label.font = style.titleFont
        label.textColor = style.titleColor
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }

    @objc func createTopBarView(frame: CGRect) -> UIView {
        let style = Screen.Style.Bar.lightContent()
        let view = UIView(frame: frame)
        view.backgroundColor = style.backgroundColor
        return view
    }
}

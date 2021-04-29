// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

/// Subclass your UIView from NibLoadView
/// to automatically load a xib with the same name
/// as your class
open class NibBasedView: UIView {

    // swiftlint:disable strong_iboutlet
    @IBOutlet weak var view: UIView!

    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        nibSetup()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }

    private func nibSetup() {
        backgroundColor = .clear

        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true

        addSubview(view)
    }

    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
    }
}

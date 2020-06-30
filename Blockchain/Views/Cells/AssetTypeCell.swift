//
//  AssetTypeCell.swift
//  Blockchain
//
//  Created by kevinwu on 10/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import ToolKit

@objc protocol AssetTypeCellDelegate {
    func didTapChevronButton()
}

// Cell shown for selecting an asset type from the drop-down
// menu (AssetSelectorView).
@objc class AssetTypeCell: UITableViewCell {

    @objc var legacyAssetType: LegacyAssetType {
        guard let asset = assetType else {
            Logger.shared.error("Unknown asset type!")
            return LegacyAssetType(rawValue: -1)!
        }
        return asset.legacy
    }
    private var assetType: CryptoCurrency?
    
    @objc weak var delegate: AssetTypeCellDelegate?
    
    @IBOutlet private var assetImageView: UIImageView!
    @IBOutlet private var label: UILabel!

    // Used to open and close the AssetSelectorView.
    @IBOutlet private var chevronButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        chevronButton.accessibilityIdentifier = AccessibilityIdentifiers.AssetSelection.toggleButton
        contentView.backgroundColor = UIColor.NavigationBar.LightContent.background
    }
    
    @objc func configure(with assetType: LegacyCryptoCurrency, showChevronButton: Bool) {
        self.assetType = assetType.value
        assetImageView.image = self.assetType?.whiteImageSmall
        label.text = assetType.name
        chevronButton.isHidden = !showChevronButton
        accessibilityIdentifier = "\(AccessibilityIdentifiers.AssetSelection.assetPrefix)\(assetType.displayCode)"
    }

    @IBAction private func chevronButtonTapped(_ sender: UIButton) {
        delegate?.didTapChevronButton()
    }
}

@objc extension AssetTypeCell {
    static func instanceFromNib() -> AssetTypeCell {
        let nib = UINib(nibName: "AssetTypeCell", bundle: Bundle.main)
        let contents = nib.instantiate(withOwner: nil, options: nil)
        return contents.first { item -> Bool in
            item is AssetTypeCell
        } as! AssetTypeCell
    }
}

@objc extension AssetTypeCell {
    func pointChevronButton(_ direction: Direction) {
        switch direction {
        case .up:
            UIView.animate(withDuration: Constants.Animation.duration) {
                self.chevronButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            }
        case .down:
            UIView.animate(withDuration: Constants.Animation.duration) {
                self.chevronButton.transform = CGAffineTransform(rotationAngle: 0)
            }
        }
    }
}

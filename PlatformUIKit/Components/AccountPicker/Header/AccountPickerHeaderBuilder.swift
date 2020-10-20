//
//  AccountPickerHeaderBuilder.swift
//  PlatformUIKit
//
//  Created by Paulo on 16/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

/// Defines a component used to build a Header UIView given the specific HeaderType.
protocol HeaderBuilder {
    associatedtype HeaderType
    func defaultHeight(for headerType: HeaderType) -> CGFloat
    func view(for headerType: AccountPickerHeaderType, fittingWidth width: CGFloat, customHeight: CGFloat?) -> UIView?
}

struct AccountPickerHeaderBuilder: HeaderBuilder {

    func defaultHeight(for headerType: AccountPickerHeaderType) -> CGFloat {
        switch headerType {
        case .none:
            return 0
        case .`default`:
            return AccountPickerHeaderModel.defaultHeight
        case .simple:
            return AccountPickerSimpleHeaderModel.defaultHeight
        }
    }

    func view(for headerType: AccountPickerHeaderType, fittingWidth width: CGFloat, customHeight: CGFloat? = nil) -> UIView? {
        let height = customHeight ?? defaultHeight(for: headerType)
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        switch headerType {
        case .none:
            return nil
        case .`default`(let model):
            let headerView = AccountPickerHeaderView(frame: frame)
            headerView.model = model
            return headerView
        case .simple(let model):
            let headerView = AccountPickerSimpleHeaderView(frame: frame)
            headerView.model = model
            return headerView
        }
    }
}

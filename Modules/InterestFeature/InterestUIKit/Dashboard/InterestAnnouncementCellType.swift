//
//  InterestAnnouncementCellType.swift
//  InterestUIKit
//
//  Created by Alex McGregor on 8/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

public enum InterestAnnouncementCellType {
    case item(LineItemCellPresenting)
    case footer(FooterTableViewCellPresenter)
    case announcement(AnnouncementCardViewModel)
    case numberedItem(BadgeNumberedItemViewModel)
    case buttons([ButtonViewModel])
}

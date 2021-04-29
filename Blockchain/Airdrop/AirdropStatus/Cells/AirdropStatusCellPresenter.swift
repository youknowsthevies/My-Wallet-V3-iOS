// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

struct AirdropStatusCellData {
    
    struct CellContent {
        let text: String
        let accessibility: Accessibility
    }

    let title: CellContent
    let value: CellContent
}

final class AirdropStatusCellPresenter {
    
    // MARK: - Properties
    
    let title: LabelContent
    let value: LabelContent
    
    init(data: AirdropStatusCellData) {
        title = LabelContent(
            text: data.title.text,
            font: .main(.medium, 14),
            color: .descriptionText,
            accessibility: data.title.accessibility
        )
        value = LabelContent(
            text: data.value.text,
            font: .main(.medium, 14),
            color: .titleText,
            accessibility: data.value.accessibility
        )
    }
}

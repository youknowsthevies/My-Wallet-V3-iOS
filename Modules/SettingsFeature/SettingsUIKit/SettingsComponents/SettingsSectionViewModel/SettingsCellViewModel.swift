// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import RxDataSources
import RxSwift
import ToolKit

struct SettingsCellViewModel {

    /// The `Action` executed when the cell is tapped
    var action: SettingsScreenAction {
        cellType.action
    }

    /// The type of cell associated with the viewModel.
    let cellType: SettingsSectionType.CellType

    /// The analytics recorder that records tap events.
    let analyticsRecorder: AnalyticsEventRecording

    init(cellType: SettingsSectionType.CellType,
         analyticsRecorder: AnalyticsEventRecording = resolve()) {
        self.analyticsRecorder = analyticsRecorder
        self.cellType = cellType
    }

    func recordSelection() {
        guard let event = cellType.analyticsEvent else { return }
        analyticsRecorder.record(event: event)
    }
}

extension SettingsCellViewModel: IdentifiableType, Equatable {

    var identity: AnyHashable {
        cellType.identity
    }

    static func == (lhs: SettingsCellViewModel, rhs: SettingsCellViewModel) -> Bool {
        lhs.cellType == rhs.cellType
    }
}

//
//  SettingsCellViewModel.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/16/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxDataSources
import RxSwift
import ToolKit

struct SettingsCellViewModel {
    
    var action: SettingsScreenAction {
        cellType.action
    }
    
    let cellType: SettingsSectionType.CellType
    let analyticsRecorder: AnalyticsEventRecording
    
    init(cellType: SettingsSectionType.CellType,
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared) {
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


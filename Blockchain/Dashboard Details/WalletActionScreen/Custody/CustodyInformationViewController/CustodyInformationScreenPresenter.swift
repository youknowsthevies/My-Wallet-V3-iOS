//
//  CustodySendInformationScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 2/3/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformUIKit
import RxSwift
import ToolKit

final class CustodyInformationScreenPresenter {
    
    // MARK: - Types
    
    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias AccessibilityId = Accessibility.Identifier.CustodyInfo
    
    // MARK: - Navigation Properties
    
    var trailingButton: Screen.Style.TrailingButton {
        .content(.init(title: nil, image: #imageLiteral(resourceName: "cancel_icon"), accessibility: .id(AccessibilityId.backButton)))
    }
    
    var leadingButton: Screen.Style.LeadingButton {
        .none
    }
    
    var titleView: Screen.Style.TitleView {
        .text(value: LocalizationID.title)
    }
    
    var barStyle: Screen.Style.Bar {
        .darkContent()
    }
    
    private typealias LocalizationID = LocalizationConstants.CustodyWalletInformation
    
    // MARK: - Public Properites
    
    var description: LabelContent {
        .init(
            text: LocalizationID.Description.partOne,
            font: .main(.medium, 14.0),
            color: .textFieldText,
            alignment: .left,
            accessibility: .id(AccessibilityId.descriptionLabel)
        )
    }
    
    var subDescription: LabelContent {
        .init(
            text: LocalizationID.Description.partTwo,
            font: .main(.medium, 14.0),
            color: .textFieldText,
            alignment: .left,
            accessibility: .id(AccessibilityId.subDescriptionLabel)
        )
    }
    
    let okButtonViewModel: ButtonViewModel
    
    // MARK: - Private Properties
    
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let disposeBag = DisposeBag()
    private unowned let stateService: CustodyActionStateServiceAPI
    
    init(stateService: CustodyActionStateServiceAPI,
         analyticsRecorder: AnalyticsEventRecorderAPI = resolve()) {
        self.stateService = stateService
        self.analyticsRecorder = analyticsRecorder
        
        analyticsRecorder.record(event: AnalyticsEvent.sbCustodyWalletCardShown)
        
        okButtonViewModel = .primary(with: LocalizationConstants.okString, accessibilityId: AccessibilityId.okButton)
        
        okButtonViewModel.tapRelay
            .map { _ in AnalyticsEvent.sbCustodyWalletCardClicked }
            .bindAndCatch(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)
        
        okButtonViewModel.tapRelay
            .bindAndCatch(to: stateService.nextRelay)
            .disposed(by: disposeBag)
    }
    
    func navigationBarTrailingButtonTapped() {
        stateService.previousRelay.accept(())
    }
}

fileprivate extension Accessibility.Identifier {
    enum CustodyInfo {
        private static let prefix = "CustodyInfoScreen."
        static let backButton = "\(prefix)backButton"
        static let descriptionLabel = "\(prefix)descriptionLabel"
        static let subDescriptionLabel = "\(prefix)subDescriptionLabel"
        static let okButton = "\(prefix)okButton"
    }
}

//
//  FiatBalanceCellProvider.swift
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import UIKit

class FiatBalanceCellProvider: FiatBalanceCellProviding {
    
    func registerFiatBalanceCell(for tableView: UITableView) {
        tableView.register(FiatCustodialBalancesTableViewCell.self)
    }
    
    func dequeueReusableFiatBalanceCell(for tableView: UITableView, indexPath: IndexPath, presenter: CurrencyViewPresenter) -> UITableViewCell {
        let cell = tableView.dequeue(FiatCustodialBalancesTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }
}

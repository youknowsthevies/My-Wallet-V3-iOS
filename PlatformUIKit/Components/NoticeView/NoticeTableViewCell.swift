//
//  NoticeTableViewCell.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 28/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

public final class NoticeTableViewCell: UITableViewCell {

    // MARK: - Properties

    public var viewModel: NoticeViewModel! {
        didSet {
            noticeView.viewModel = viewModel
        }
    }

    private let noticeView = NoticeView()

    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(noticeView)
        noticeView.layoutToSuperview(axis: .horizontal, offset: 24)
        noticeView.layoutToSuperview(axis: .vertical, offset: 16, priority: .penultimateHigh)
        noticeView.layoutToSuperview(.centerY)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }
}

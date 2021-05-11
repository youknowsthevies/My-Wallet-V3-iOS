// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public final class SimpleHeaderView: UITableViewHeaderFooterView {

    public var text: String {
        get {
            label.text ?? ""
        }
        set {
            label.text = newValue
        }
    }
    
    private lazy var label = UILabel()
        
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        let backgroundView = UIView()
        backgroundView.backgroundColor = .background
        self.backgroundView = backgroundView
        
        label.layoutToSuperview(axis: .horizontal, offset: 16)
        label.layoutToSuperview(axis: .vertical, offset: 10)
        label.font = .main(.medium, 12)
        label.textColor = .descriptionText
        label.verticalContentHuggingPriority = .required
        label.verticalContentCompressionResistancePriority = .required
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol PickerViewSelectable {
    var id: String { get }
    var title: String { get }
}

extension String: PickerViewSelectable {
    
    var id: String {
        self
    }
    
    var title: String {
        self
    }
}

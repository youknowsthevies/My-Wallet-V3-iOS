@_exported import Foundation

extension String {

    @inlinable public func localized(
        tableName: String? = nil,
        bundle: Bundle = Bundle.main,
        value: String = "",
        comment: String = ""
    ) -> String {
        NSLocalizedString(self, tableName: tableName, bundle: bundle, value: value, comment: comment)
    }
}

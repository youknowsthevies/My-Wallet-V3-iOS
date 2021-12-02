// Source: https://gist.githubusercontent.com/nil-biribiri/67f158c8a93ff0a5d8c99ff41d8fe3bd/raw/d267a9af6876826169b054007cf6b76f95dd6a24/DispatchOnce.swift

import Foundation

extension DispatchQueue {

    private static var _onceTracker = Set<String>()

    /**
      Executes a block of code, associated with a auto generate unique token by file name + fuction name + line of code, only once.  The code is thread safe and will
      only execute the code once even in the presence of multithreaded calls.
     */
    public class func once(
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        block: () -> Void
    ) {
        let token = "\(file):\(function):\(line)"
        once(token: token, block: block)
    }

    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.

     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block: () -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        guard !_onceTracker.contains(token) else { return }
        _onceTracker.insert(token)
        block()
    }
}

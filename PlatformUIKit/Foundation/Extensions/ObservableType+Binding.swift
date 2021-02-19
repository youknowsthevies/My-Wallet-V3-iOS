//
//  ObservableType+Binding.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 29/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa
import ToolKit

extension ObservableType {

    public func bindAndCatch<A: AnyObject>(
        file: String = #file,
        line: Int = #line,
        function: String = #function,
        weak object: A,
        onNext: @escaping (A, Element) -> Void
    ) -> Disposable {
        _bind(
            onNext: { [weak object] element in
                guard let object = object else { return }
                onNext(object, element)
            },
            file: file,
            line: line,
            function: function
        )
    }

    public func bindAndCatch<A: AnyObject>(
        file: String = #file,
        line: Int = #line,
        function: String = #function,
        weak object: A,
        onNext: @escaping (A) -> Void
    ) -> Disposable {
        _bind(
            onNext: { [weak object] element in
                guard let object = object else { return }
                onNext(object)
            },
            file: file,
            line: line,
            function: function
        )
    }

    private func _bind(
        onNext: @escaping (Element) -> Void,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) -> Disposable {
        self.do(onError: { error in
            fatalError("Binding error. file: \(file), line: \(line), function: \(function), error: \(error).")
        })
        .bind(onNext: onNext)
    }
}

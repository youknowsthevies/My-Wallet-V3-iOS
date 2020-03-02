//
//  ObservableTypeExtensions.swift
//  PlatformKit
//
//  Created by Jack on 09/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol OptionalType {
    associatedtype Wrapped
    
    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    public var value: Wrapped? {
        return self
    }
}

extension ObservableType where Element: OptionalType {
    func onNil(error: Error) -> Observable<Element.Wrapped> {
        return flatMap { element -> Observable<Element.Wrapped> in
            guard let value = element.value else {
                return Observable<Element.Wrapped>.error(error)
            }
            return Observable<Element.Wrapped>.just(value)
        }
    }
}

extension ObservableType {
    public func map<A: AnyObject, R>(weak object: A, _ selector: @escaping (A, Element) throws -> R) -> Observable<R> {
        return map { [weak object] element -> R in
            guard let object = object else { throw ToolKitError.nullReference(A.self) }
            return try selector(object, element)
        }
    }
}

extension ObservableType {
    public func flatMap<A: AnyObject, R>(weak object: A, selector: @escaping (A, Self.Element) throws -> Observable<R>) -> Observable<R> {
        return flatMap { [weak object] (value) -> Observable<R> in
            guard let object = object else {
                return Observable.error(ToolKitError.nullReference(A.self))
            }
            return try selector(object, value)
        }
    }

    public func flatMapLatest<A: AnyObject, R>(weak object: A, selector: @escaping (A, Self.Element) throws -> Observable<R>) -> Observable<R> {
        return flatMapLatest { [weak object] (value) -> Observable<R> in
            guard let object = object else {
                return Observable.error(ToolKitError.nullReference(A.self))
            }
            return try selector(object, value)
        }
    }
}

// MARK: - Creation (weak: self)

extension ObservableType {
    public static func create<A: AnyObject>(weak object: A, subscribe: @escaping (A, (AnyObserver<Element>)) -> Disposable) -> Observable<Element> {
        return Observable<Element>.create { [weak object] observer -> Disposable in
            guard let object = object else {
                observer.on(.error(ToolKitError.nullReference(A.self)))
                return Disposables.create()
            }
            return subscribe(object, observer)
        }
    }
}

// MARK: - Catch Error Op

extension ObservableType {
    public func catchError<A: AnyObject>(weak object: A, _ selector: @escaping (A, Swift.Error) throws -> Observable<Element>) -> Observable<Element> {
        return catchError { [weak object] error -> Observable<Element> in
            guard let object = object else { throw ToolKitError.nullReference(A.self) }
            return try selector(object, error)
        }
    }
}

// MARK: - Result<Element, Error> mapping

extension ObservableType {
    
    /// Directly maps to `Result<Element, Error>` type.
    public func mapToResult() -> Observable<Result<Element, Error>> {
        self.map { .success($0) }
            .catchError { .just(.failure($0)) }
    }
    
    /// Map with success and failure mappers.
    /// This is useful in case we would like to have a custom error type.
    public func mapToResult<ResultElement, OutputError: Error>(
        successMap: @escaping (Element) -> ResultElement,
        errorMap: @escaping (Error) -> OutputError) -> Observable<Result<ResultElement, OutputError>> {
        self.map { .success(successMap($0)) }
            .catchError { .just(.failure(errorMap($0))) }
    }
    
    /// Map with success mapper only.
    public func mapToResult<ResultElement>(
        successMap: @escaping (Element) -> ResultElement) -> Observable<Result<ResultElement, Error>> {
        self.map { .success(successMap($0)) }
            .catchError { .just(.failure($0)) }
    }
}

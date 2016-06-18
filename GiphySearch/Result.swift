//
//  Result.swift
//  GiphySearch
//
//  Created by Kyle Fang on 6/18/16.
//  Copyright © 2016 Kyle Fang. All rights reserved.
//

import Foundation
import RxSwift

enum Result<T> {
    case Success(T)
    case Error(ErrorType)
}

extension Result {
    func flatMap<U>(function: T->Result<U>) -> Result<U> {
        switch self {
        case .Success(let value): return function(value)
        case .Error(let error): return .Error(error)
        }
    }
    var value: T? {
        switch self {
        case .Success(let value): return value
        default: return nil
        }
    }
    
    func toObservable() -> Observable<T> {
        switch self {
        case .Success(let value): return .just(value)
        case .Error(let error): return .error(error)
        }
    }
    
    func toParser() -> Parser<T> {
        switch self {
        case .Success(let value): return .unit(value)
        case .Error(let error): return .failed(error)
        }
    }
}
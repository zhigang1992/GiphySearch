//
//  Cache.swift
//  GiphySearch
//
//  Created by Kyle Fang on 6/18/16.
//  Copyright © 2016 Kyle Fang. All rights reserved.
//

import Foundation
import RxSwift

final class Cache<T> {
    var cachedValue:T?
    
    func get(withFallbackRequest request: Observable<T>) -> Observable<T> {
        if let cached = cachedValue {
            return .just(cached)
        } else {
            return request.doOnNext({self.cachedValue = $0})
        }
    }
    
    func resetCache() -> Cache {
        cachedValue = nil
        return self
    }
}
//
//  RxSwiftExtension.swift
//  GiphySearch
//
//  Created by Kyle Fang on 6/18/16.
//  Copyright © 2016 Kyle Fang. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct Lens<T> {
    let getter: ()->T
    let setter: T->()
}

extension Observable where Element : Equatable {
    func bindTo(lens: Lens<Element>) -> Disposable {
        return self.filter({ $0 != lens.getter() }).subscribeNext(lens.setter)
    }
}

extension Driver where Element : Equatable {
    func bindTo(lens: Lens<Element>) -> Disposable {
        return self.filter({ $0 != lens.getter() }).driveNext(lens.setter)
    }
}

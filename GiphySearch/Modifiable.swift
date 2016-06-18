//
//  Modifiable.swift
//  GiphySearch
//
//  Created by Kyle Fang on 6/18/16.
//  Copyright © 2016 Kyle Fang. All rights reserved.
//

import Foundation

protocol Modifiable: class {
}

extension Modifiable {
    func modify(modification: Self -> Void) -> Self {
        modification(self)
        return self
    }
}

extension NSObject : Modifiable {}
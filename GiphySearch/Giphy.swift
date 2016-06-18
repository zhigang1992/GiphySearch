//
//  Giphy.swift
//  GiphySearch
//
//  Created by Kyle Fang on 6/18/16.
//  Copyright © 2016 Kyle Fang. All rights reserved.
//

import Foundation
import Curry

struct Giphy {
    let id: String
    let slug: String
    let url: String
    let images: String
}

extension Giphy: Parsable {
    static var parser: Parser<Giphy> {
        return curry(self.init)
            <^> "id"
            <*> "slug"
            <*> "url"
            <*> "images.fixed_width.url"
    }
}


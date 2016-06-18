//
//  GiphySearchTests.swift
//  GiphySearchTests
//
//  Created by Kyle Fang on 6/18/16.
//  Copyright © 2016 Kyle Fang. All rights reserved.
//

@testable import GiphySearch
import Quick

class QuickConfig: QuickConfiguration {
    override class func configure(configuration: Configuration) {
        configuration.beforeEach {
            Injector.reset()
        }
    }
}

extension Injector {
    static func registerMock<T>(type:T.Type, withFactory factory:()->T) {
        self.sharedContainer.register(type, factory: {_ in return factory() })
    }
}
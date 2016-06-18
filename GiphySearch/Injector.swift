//
//  Injector.swift
//  GiphySearch
//
//  Created by Kyle Fang on 6/18/16.
//  Copyright © 2016 Kyle Fang. All rights reserved.
//

import Foundation
import Swinject

struct Injector {
    static func initialRegisteration(container: Container) {
        container.register(HomeViewModel.self) { _ in HomeViewModel() }
        container.register(NSURLSession.self) { _ in .sharedSession() }
        container.register(GiphyAPIType.self, factory: { _ in GiphyAPI() })
    }
    
    static private(set) var sharedContainer = Container(registeringClosure: Injector.initialRegisteration)
    
    static func resolve<T>(type: T.Type) -> T {
        return self.sharedContainer.resolve(type)!
    }
    
    // mainly for testing
    static func reset() {
        self.sharedContainer = Container(registeringClosure: Injector.initialRegisteration)
    }
}
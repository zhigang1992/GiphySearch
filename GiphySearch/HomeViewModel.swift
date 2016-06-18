//
//  ViewModel.swift
//  GiphySearch
//
//  Created by Kyle Fang on 6/18/16.
//  Copyright © 2016 Kyle Fang. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ViewModel {
    
    struct State {
        var isSearching: Bool = false
        var searchingText: String = ""
        var isLoading: Bool = false
        var data: [Giphy] = []
    }
    
    private let api = Injector.resolve(GiphyAPIType)
    
    private var state = Variable(State())
    
    lazy var driver: Driver<State> = self.state.asDriver()
}
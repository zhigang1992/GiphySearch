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

class HomeViewModel {
    
    let giphys = Variable<[Giphy]>([])
    
    let searchingText = PublishSubject<String>()
    let isSearching = Variable<Bool>(false)
    
    private let api = Injector.resolve(GiphyAPIType)
    
    private let trendingCache = Cache<[Giphy]>()
    
    private let disposeBag = DisposeBag()
    init(throttle: NSTimeInterval = 1) {
        
        let trending = self.trendingCache.get(withFallbackRequest: api.trending())
        
        let searching = searchingText.throttle(throttle, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map({[unowned self] in $0.isEmpty ? trending : self.api.search($0)})
            .switchLatest()
        
        isSearching.asObservable()
            .flatMap({ $0 ? searching : trending })
            .subscribeNext({[unowned self] in
                self.giphys.value = $0
            })
            .addDisposableTo(self.disposeBag)
    }
    
    func refresh() -> Observable<()> {
        return trendingCache.resetCache()
            .get(withFallbackRequest: api.trending())
            .doOnNext({[unowned self] giphys in
                if !self.isSearching.value {
                    self.giphys.value = giphys
                }
            })
            .map({_ in ()})
    }
}


//
//  GiphyAPITest.swift
//  GiphySearch
//
//  Created by Kyle Fang on 6/18/16.
//  Copyright © 2016 Kyle Fang. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RxSwift
import RxBlocking

@testable import GiphySearch

extension Giphy {
    static func fakeGiphyWith(id id:String) -> Giphy {
        return Giphy(id: id, slug: "slug", url: "url", images: "imageurl")
    }
}

struct FakeGiphyAPI : GiphyAPIType  {
    let delay: NSTimeInterval
    
    func delayObservable() -> Observable<Int> {
        return Observable.timer(delay, scheduler: MainScheduler.instance)
    }
    
    func trending() -> Observable<[Giphy]> {
        return delayObservable().map({ _ in [.fakeGiphyWith(id: "trending")] })
    }
    
    func search(keyword: String) -> Observable<[Giphy]> {
        return delayObservable().map({ _ in [.fakeGiphyWith(id: keyword)] })
    }
}

class HomeViewModelSpecs: QuickSpec {
    override func spec() {
        describe("HomeViewModelSpecs") {
            
            beforeEach({
                Injector.registerMock(GiphyAPIType.self) { _ in FakeGiphyAPI(delay: 0) }
            })
            
            context("Trending") {
                it("should initial with trending giphy") {
                    let viewModel = HomeViewModel(throttle: 0)
                    expect(viewModel.giphys.value.first?.id).toEventually(equal("trending"))
                }
            }
            
            context("Searching") {
                it("should render search result") {
                    let viewModel = HomeViewModel(throttle: 0)
                    viewModel.isSearching.value = true
                    viewModel.searchingText.onNext("Hello")
                    expect(viewModel.giphys.value.first?.id).toEventually(equal("Hello"))
                }
                
                it("should wait for 1 second timeout before search") {
                    let viewModel = HomeViewModel(throttle: 1)
                    viewModel.isSearching.value = true
                    viewModel.searchingText.onNext("Hello")
                    
                    waitUntil(timeout: 2) { done in
                        let id = viewModel.giphys.asDriver().map({$0.first?.id})
                        _ = id.asObservable().take(1).subscribeNext({
                            if $0 != "trending" { fail("first id should be trending") }
                        })
                        _ = id.skip(1).driveNext({
                            if $0 == "Hello" { done() }
                        })
                    }
                }
            }
        }
    }
}
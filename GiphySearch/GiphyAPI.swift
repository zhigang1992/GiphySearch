//
//  GiphyAPI.swift
//  GiphySearch
//
//  Created by Kyle Fang on 6/18/16.
//  Copyright © 2016 Kyle Fang. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol GiphyAPIType {
    func trending() -> Observable<[Giphy]>
    func search(keyword:String) -> Observable<[Giphy]>
}

private let treandingAPI = NSURL(string: "https://api.giphy.com/v1/gifs/trending?api_key=dc6zaTOxFJmzC")!

private func searchAPI(keyword: String) -> NSURL {
    let keywordQuery = keyword.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    let url = "https://api.giphy.com/v1/gifs/search?q=\(keywordQuery ?? "")&api_key=dc6zaTOxFJmzC"
    return NSURL(string: url)!
}

struct GiphyAPI : GiphyAPIType {
    let session: NSURLSession = Injector.resolve(NSURLSession.self)
    
    let responseParser = dictionaryParser(
        key: "data",
        parser: arrayParser(Giphy.parser)
    )
    
    func trending() -> Observable<[Giphy]> {
        return session.rx_JSON(treandingAPI)
            .flatMap({ self.responseParser.parse($0).toObservable() })
    }
    func search(keywords: String) -> Observable<[Giphy]> {
        return session.rx_JSON(searchAPI(keywords))
            .flatMap({self.responseParser.parse($0).toObservable()})
    }
}
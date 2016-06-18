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

import RxAlamofire

protocol GiphyAPIType {
    func trending() -> Observable<[Giphy]>
    func search(keyword:String) -> Observable<[Giphy]>
}

private func searchAPI(keyword: String) -> String {
    let keywordQuery = keyword.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    return "https://api.giphy.com/v1/gifs/search?q=\(keywordQuery ?? "")&api_key=dc6zaTOxFJmzC"
}

struct GiphyAPI : GiphyAPIType {
    
    let responseParser = dictionaryParser(
        key: "data",
        parser: arrayParser(Giphy.parser)
    )
    
    func trending() -> Observable<[Giphy]> {
        return JSON(.GET, "https://api.giphy.com/v1/gifs/trending?api_key=dc6zaTOxFJmzC")
            .flatMap({ self.responseParser.parse($0).toObservable() })
    }
    func search(keywords: String) -> Observable<[Giphy]> {
        return JSON(.GET, searchAPI(keywords))
            .flatMap({self.responseParser.parse($0).toObservable()})
    }
}
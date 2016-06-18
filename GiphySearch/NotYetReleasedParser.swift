//
//  NotYetReleasedParser.swift
//  GiphySearch
//
//  Created by Kyle Fang on 6/18/16.
//  Copyright © 2016 Kyle Fang. All rights reserved.
//


// Please don't look at the code here... :(
// It's WIP
import Foundation

extension String : ErrorType {
    
}

struct Parser<T> {
    let parse: (AnyObject) -> Result<T>
}

extension Parser {
    
    static func failed(error: ErrorType) -> Parser<T> {
        return Parser { _ in .Error(error) }
    }
    
    static func unit(value:T) -> Parser<T> {
        return Parser { _ in .Success(value) }
    }
    
    func flatMap<U>(function: T-> Parser<U>) -> Parser<U> {
        return Parser<U> { input in
            self.parse(input).flatMap({function($0).parse(input)})
        }
    }
    
    func map<U>(function: T->U) -> Parser<U> {
        return self.flatMap({.unit(function($0))})
    }
    
    func apply<U>(applicative: Parser<T->U>) -> Parser<U> {
        return applicative.flatMap({self.map($0)})
    }
    
}

infix operator <^> { associativity left }
infix operator <*> { associativity left }

func <^><T, U>(left: T->U, right: Parser<T>) -> Parser<U> {
    return right.map(left)
}

func <*><T, U>(left: Parser<T->U>, right: Parser<T>) -> Parser<U> {
    return right.apply(left)
}

func dictionaryParser<T>(key key: String, parser: Parser<T>) -> Parser<T> {
    let keys = key.componentsSeparatedByString(".").reverse()
    return keys.reduce(parser, combine: { loop, currentKey in
        return Parser<T> { input in
            guard let dictionary = input as? NSDictionary else {
                return .Error("\(input) is not an dictionary")
            }
            guard let value = dictionary[currentKey] else {
                return .Error("key \(currentKey) does not exist in \(input)")
            }
            return loop.parse(value)
        }
    })
}

func arrayParser<T>(parser:Parser<T>) -> Parser<[T]> {
    let arrayOfAnyObject = Parser<NSArray> { input in
        guard let array = input as? NSArray else {
            return .Error("\(input) is not an array")
        }
        return .Success(array)
    }
    return arrayOfAnyObject.flatMap({ array in
        let arrayOfParser = array.map({parser.parse($0).toParser()})
        return arrayOfParser.reduce(.unit([])) { loop, nextParser in
            {result in {next in result+[next]}} <^> loop <*> nextParser
        }
    })
}

func optionalParser<T>(parser:Parser<T>) -> Parser<Optional<T>> {
    return Parser { input  in
        if case .Success(let value) = parser.parse(input) {
            return .Success(value)
        }
        return .Success(nil)
    }
}

func <^><T:Parsable, U>(left: T->U, key: String ) -> Parser<U> {
    return left <^> dictionaryParser(key: key, parser: T.parser)
}

func <*><T:Parsable, U>(left: Parser<T->U>, key: String) -> Parser<U> {
    return left <*> dictionaryParser(key: key, parser: T.parser)
}

//: These are workaround because swift's lack of support in partial confirm to protocol, you can't do `extension Array: Parsable where Element: Parsable`
func <^><T:Parsable, U>(left: [T]->U, key: String ) -> Parser<U> {
    return left <^> dictionaryParser(
        key: key,
        parser: arrayParser(T.parser)
    )
}

func <*><T:Parsable, U>(left: Parser<[T]->U>, key: String) -> Parser<U> {
    return left <*> dictionaryParser(
        key: key,
        parser: arrayParser(T.parser)
    )
}

func <^><T:Parsable, U>(left: Optional<T>->U, key: String ) -> Parser<U> {
    return left <^> optionalParser(dictionaryParser(key: key,parser: T.parser))
}

func <*><T:Parsable, U>(left: Parser<Optional<T>->U>, key: String) -> Parser<U> {
    return left <*> optionalParser(dictionaryParser(key: key,parser: T.parser))
}

protocol Parsable {
    static var parser: Parser<Self> { get }
}

extension Double: Parsable {
    static var parser: Parser<Double> {
        return Parser {
            if let number = $0 as? Double {
                return .Success(number)
            }
            return .Error("\($0) is not an number")
        }
    }
}

extension Int: Parsable {
    static var parser: Parser<Int> {
        return Double.parser.map(Int.init)
    }
}

extension String: Parsable {
    static var parser: Parser<String> {
        return Parser {
            if let string = $0 as? String {
                return .Success(string)
            }
            return .Error("\($0) is not an string")
        }
    }
}


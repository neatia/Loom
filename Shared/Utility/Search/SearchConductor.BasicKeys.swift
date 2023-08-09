//
//  SearchConductor.BasicKeys.swift
//  Loom
//
//  Created by Ritesh Pakala on 8/9/23.
//

import Foundation

protocol Searchable {
    var searchId: String { get }
}

struct BasicKeySearchBox {
    var keys: [String]
    
    func search(_ query: String) -> [String] {
        query.suggestions(keys)
    }
}


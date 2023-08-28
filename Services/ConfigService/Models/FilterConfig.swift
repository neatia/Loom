//
//  FilterConfig.swift
//  Loom
//
//  Created by PEXAVC on 8/27/23.
//

import Foundation
import Granite

struct FilterConfig: GraniteModel {
    let keywords: [Keyword]
    
    enum ContentAttribute: GraniteModel {
        case title
        case body
        case link
        case creator
    }
    
    struct Keyword: GraniteModel {
        let value: String
        let attribute: ContentAttribute
    }
    
    static var empty: FilterConfig {
        .init(keywords: [])
    }
}

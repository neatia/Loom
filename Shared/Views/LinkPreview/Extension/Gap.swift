//
//  Gap.swift
//  URLEmbeddedView
//
//  Created by marty-suzuki on 2018/07/07.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Foundation

#if swift(>=4.1)
    // nothing
#else
    extension Sequence {
        public func compactMap<ElementOfOGResult>(_ transform: (Element) throws -> ElementOfOGResult?) rethrows -> [ElementOfOGResult] {
            return try flatMap(transform)
        }
    }
#endif

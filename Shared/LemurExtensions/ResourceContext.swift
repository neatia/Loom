//
//  ResourceContext.swift
//  Loom
//
//  Created by PEXAVC on 8/7/23.
//

import Foundation
import LemmyKit

struct ResourceContext {
    var resource: ResourceType
    var ancestor: ResourceType?
    
    var location: FetchType
}

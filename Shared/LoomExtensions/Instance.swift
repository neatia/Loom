//
//  Instance.swift
//  Loom
//
//  Created by PEXAVC on 8/8/23.
//

import Foundation
import LemmyKit

extension Instance: GlobeNode {
    public var nodeId: String {
        self.domain
    }
    
    public static var base: Instance {
        .init(id: LemmyKit.current.instanceId ?? -1,
              domain: LemmyKit.host,
              published: LemmyKit.current.metadata?.site.published ?? "")
    }
}



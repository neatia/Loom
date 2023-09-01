//
//  Instance.swift
//  Loom
//
//  Created by PEXAVC on 8/8/23.
//

import Foundation
import FederationKit

extension FederatedInstance: GlobeNode {
    public var nodeId: String {
        self.domain
    }
    
    public static var base: FederatedInstance {
        .init(FederationKit.currentInstanceType,
              id: (FederationKit.metadata()?.site.instance_id ?? 0.randomBetween(100000)).asString,
              domain: FederationKit.host,
              published: FederationKit.metadata()?.site.published ?? "")
    }
}



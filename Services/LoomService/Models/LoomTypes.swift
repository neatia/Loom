//
//  LoomTypes.swift
//  Loom
//
//  Created by Ritesh Pakala on 8/17/23.
//

import Foundation
import LemmyKit
import Granite

/* FederationKit */

protocol FederatedCommunity: Codable, Decodable {
    var instanceType: FederatedInstanceType { get }
    
    var id: String { get }
    var displayName: String { get }
    var actor_id: String { get }
    
    var lemmy: CommunityView? { get }
}

protocol FederatedInstance: Codable, Decodable {
    var instanceType: FederatedInstanceType { get }
    
    var domain: String { get }
}

extension FederatedInstance {
    var id: String { domain }
}

enum FederatedInstanceType: String {
    case lemmy
}

/* Lemmy extensions */

extension CommunityView: FederatedCommunity {
    var lemmy: CommunityView? {
        self
    }
    
    var instanceType: FederatedInstanceType {
        .lemmy
    }
    
    var actor_id: String {
        self.community.actor_id
    }
}

extension Instance: FederatedInstance {
    var instanceType: FederatedInstanceType {
        .lemmy
    }
}


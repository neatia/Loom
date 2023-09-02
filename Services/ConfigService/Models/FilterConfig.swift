//
//  FilterConfig.swift
//  Loom
//
//  Created by PEXAVC on 8/27/23.
//

import Foundation
import Granite
import FederationKit

struct FilterConfig: GraniteModel {
    let keywords: [Keyword]
    
    enum ContentAttribute: String, GraniteModel {
        case title
        case body
        case link
        case communityName
        case creator
        case instanceLink
    }
    
    struct Keyword: GraniteModel, Identifiable {
        let value: String
        let attributes: [ContentAttribute]
        
        var id: String {
            value
        }
        
        struct Check {
            var title: String
            var body: String
            var link: String
            var communityName: String
            var creator: String
            var instanceLink: String
        }
    }
    
    static var empty: FilterConfig {
        .init(keywords: [])
    }
}

extension FilterConfig {
    func check(post resource: FederatedPostResource) -> Bool {
        keywords.first(where: { $0.check(post: resource) }) != nil
    }
    
    func check(comment resource: FederatedCommentResource) -> Bool {
        keywords.first(where: { $0.check(comment: resource) }) != nil
    }
}

extension FilterConfig.Keyword {
    func check(post resource: FederatedPostResource) -> Bool {
        var found: Bool = false
        for attribute in attributes {
            switch attribute {
            case .title:
                found = resource.post.name.includes([value])
            case .body:
                found = resource.post.body?.includes([value]) == true
            case .link:
                found = resource.post.url?.includes([value]) == true
            case .communityName:
                found = resource.community.name.includes([value])
            case .creator:
                found = resource.creator.name.includes([value])
            case .instanceLink:
                found = resource.creator.actor_id.includes([value])
                if !found {
                    found = resource.post.ap_id.includes([value])
                }
            }
            
            if found {
                break
            }
        }
        return found
    }
    
    func check(comment resource: FederatedCommentResource) -> Bool {
        var found: Bool = false
        for attribute in attributes {
            switch attribute {
            case .title:
                found = false
            case .body:
                found = resource.comment.content.includes([value])
            case .link:
                found = false
            case .communityName:
                found = resource.community.name.includes([value])
            case .creator:
                found = resource.creator.name.includes([value])
            case .instanceLink:
                found = resource.creator.actor_id.includes([value])
                if !found {
                    found = resource.comment.ap_id.includes([value])
                }
            }
            
            if found {
                break
            }
        }
        return found
    }
}

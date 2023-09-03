import Granite
import IPFSKit
import Foundation
import SwiftUI
import FederationKit

extension Write {
    struct Create: GraniteReducer {
        typealias Center = Write.Center
        
        struct ResponseMeta: GranitePayload {
            var postView: FederatedPostResource
        }
        
        @Relay var config: ConfigService
        
        func reduce(state: inout Center.State) async {
            config.preload()
            
            let title = state.title
            let content = state.content.trimmingCharacters(in: .whitespacesAndNewlines)
            let imageData = state.imageData
            let postURL = state.postURL
            let postCommunity = state.postCommunity
            let enableIPFS: Bool = config.state.enableIPFS && config.state.isIPFSAvailable
            let ipfsContentStyle: Int = config.state.ipfsContentType
            
            state.isPosting = false
            
            guard postCommunity?.community != nil || state.isEditing else {
                return
            }
            
            let url: String?
            var subcontent: String = ""
            var includeBody: Bool = true
            if enableIPFS && content.isNotEmpty {
                let ipfsContent = await prepareIPFS(imageData: imageData, postURL: postURL, ipfsContentStyle: ipfsContentStyle, title: title, content: content)
                
                url = ipfsContent?.postUrl ?? postURL
                subcontent = ipfsContent?.subcontent ?? ""
                
                if ipfsContentStyle == 2 {
                    includeBody = false
                }
            } else {
                url = postURL
            }
            
            let value: FederatedPostResource?
            //TODO: nsfw and languageid options
            
            if let id = state.editingFederatedPostResource?.post.id {
                value = await Federation.editPost(id,
                                             title: title,
                                             url: url?.isEmpty == true ? nil : url,
                                             body: includeBody ? (content + subcontent) : nil)
                
                //TODO: edit failed error
                
                
                if let value {
                    beam.send(ResponseMeta(postView: value))
                }
            } else if let community = postCommunity?.community {
                
                value = await Federation.createPost(title,
                                                    url: url?.isEmpty == true ? nil : url,
                                                    body: includeBody ? (content + subcontent) : nil,
                                                    community: community)
                
                guard let value else {
                    beam.send(StandardNotificationMeta(title: "MISC_ERROR_2", message: "ALERT_CREATE_POST_FAILED \("!"+community.name)", event: .error))
                    return
                }
                
                state.createdFederatedPostResource = value
                state.showPost = true
                
                
                GraniteNavigation
                    .router(for: state.routerId)
                    .push(style: .customTrailing(Color.background)) {
                    PostDisplayView()
                        .contentContext(.init(postModel: value))
                }
            } else {
                value = nil
            }
        }
        
        struct IPFSContent {
            var imageUrl: String
            var postUrl: String
            var content: String
            var subcontent: String
        }
        func prepareIPFS(imageData: Data?, postURL: String, ipfsContentStyle: Int, title: String, content: String) async -> IPFSContent? {
            
            let image_url: String
            
            if let imageData {
                let response = await IPFS.upload(imageData)
                
                guard let ipfsURL = IPFSKit.gateway?.genericURL(for: response) else {
                    image_url = "https://stoic-static-files.s3.us-west-1.amazonaws.com/neatia/neatia.png"
                    return nil
                }
                image_url = ipfsURL.absoluteString
            } else {
                image_url = "https://stoic-static-files.s3.us-west-1.amazonaws.com/neatia/neatia.png"
            }
            
            let currentUser = FederationKit.user()?.resource.user.person
            let user = currentUser?.name ?? ""
            let actorUrl = currentUser?.actor_id ?? ""
            
            var subcontent: String = ""
            
            let text: String
            
            if ipfsContentStyle == 0 {
                text = Write.Generate.htmlMarkdown(title: title, author: user, content: content, urlString: actorUrl, image_url: image_url)
            } else if ipfsContentStyle == 1 {
                text = Write.Generate.htmlReader(title: title, author: user, content: Array(content.components(separatedBy: "\n")).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }, urlString: actorUrl, image_url: image_url)
            } else {
                text = Write.Generate.shader(title: title, author: user, content: content.trimmingCharacters(in: .whitespacesAndNewlines), urlString: actorUrl, image_url: image_url)
            }
            
            guard let data: Data = text.data(using: .utf8) else {
                return nil
            }
            
            let response = await IPFS.upload(data)
            guard let ipfsURL = IPFSKit.gateway?.genericURL(for: response) else {
                return nil
            }
            
            LoomLog("\(ipfsURL)", level: .debug)
            
            let url = ipfsURL.absoluteString
            subcontent += "\n\n[preserved](\(ipfsURL.absoluteString))"
            
            return .init(imageUrl: image_url, postUrl: url, content: content, subcontent: subcontent)
        }
        
        var behavior: GraniteReducerBehavior {
            .task(.userInitiated)
        }
    }
}


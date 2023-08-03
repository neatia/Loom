import Granite
import LemmyKit
import IPFSKit
import Foundation

extension Write {
    struct Create: GraniteReducer {
        typealias Center = Write.Center
        
        struct ResponseMeta: GranitePayload {
            var postView: PostView
        }
        
        @Relay var config: ConfigService
        
        func reduce(state: inout Center.State) {
            
            let title = state.title
            let content = state.content.trimmingCharacters(in: .whitespacesAndNewlines)
            let imageData = state.imageData
            let postURL = state.postURL
            let postCommunity = state.postCommunity
            let enableIPFS: Bool = config.state.enableIPFS && config.state.isIPFSAvailable
            let ipfsContentStyle: Int = state.selectedIPFSContentStyle
            _ = Task {
                guard let community = postCommunity?.community else {
                    return
                }
                
                _ = Task.detached {
                    let url: String?
                    var subcontent: String = ""
                    if enableIPFS && content.isNotEmpty {
                        let ipfsContent = await prepareIPFS(imageData: imageData, postURL: postURL, ipfsContentStyle: ipfsContentStyle, title: title, content: content)
                        
                        url = ipfsContent?.postUrl ?? postURL
                        subcontent = ipfsContent?.subcontent ?? ""
                    } else {
                        url = postURL
                    }
                    
                    let value = await Lemmy.createPost(title,
                                                       content: content,
                                                       url: url?.isEmpty == true ? nil : url,
                                                       body: content + subcontent,
                                                       community: community)
                    
                    guard let value else {
                        beam.send(StandardNotificationMeta(title: "MISC_ERROR_2", message: "ALERT_CREATE_POST_FAILED \("!"+community.name)", event: .error))
                        return
                    }
                    beam.send(ResponseMeta(postView: value))
                }
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
            
            let user = LemmyKit.current.user?.local_user_view.person.name ?? ""
            let actorUrl = (LemmyKit.current.user?.local_user_view.person.actor_id ?? "")
            
            //<p>Water <em></em></p>
            //1483605673
            //309689082
            //621271593
            //622435653
            //724784662
            //1278332455
            
            var subcontent: String = ""
            
            let text: String
            
            if ipfsContentStyle == 0 {
                text = Write.Generate.htmlMarkdown(title: title, author: user, content: content, urlString: actorUrl, image_url: image_url)
            } else {
                text = Write.Generate.htmlReader(title: title, author: user, content: Array(content.components(separatedBy: "\n")).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }, urlString: actorUrl, image_url: image_url)
            }
            
            guard let data: Data = text.data(using: .utf8) else {
                return nil
            }
            
            let response = await IPFS.upload(data)
            
            guard let ipfsURL = IPFSKit.gateway?.genericURL(for: response) else {
                return nil
            }
            
            let url = ipfsURL.absoluteString
            subcontent += "\n\n[preserved](\(ipfsURL.absoluteString))"
            
            return .init(imageUrl: image_url, postUrl: url, content: content, subcontent: subcontent)
        }
    }
    
    
}


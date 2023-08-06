import Granite
import LemmyKit
import SwiftUI
import Combine

struct Feed: GraniteComponent {
    @Command var center: Center
    
    @Relay var config: ConfigService
    @Relay var modal: ModalService
    @Relay var account: AccountService
    
    @StateObject var pager: Pager<PostView> = .init(emptyText: "EMPTY_STATE_NO_POSTS")
    
    var listeners: Void {
        account
            .center
            .interact
            .listen(.broadcast) { value in
                if let response = value as? AccountService.Interact.ResponseMeta {
                    switch response.intent {
                    case .blockPersonFromPost(let model):
                        pager.block(item: model)
                    case .blockPerson(let model):
                        pager.updateBlockFromPerson(item: model)
                    case .removePost(let model):
                        pager.update(item: model)
                    case .subscribe(let model):
                        _state.community.wrappedValue = model.community
                        _state.communityView.wrappedValue = model
                    default:
                        break
                    }
                    modal.presentModal(GraniteToastView(response.notification))
                }
            }
        
        account
            .center
            .interact
            .listen(.beam) { value in
                if let meta = value as? AccountService.Interact.Meta {
                    switch meta.intent {
                    case .reportPost(let model):
                        modal.presentSheet {
                            ReportView(kind: .post(model))
                        }
                    case .reportComment(let model):
                        modal.presentSheet {
                            ReportView(kind: .comment(model))
                        }
                    default:
                        break
                    }
                }
            }
    }
    
    init(_ community: Community? = nil) {
        _center = .init(.init(community: community))
        //content.preload()
    }
}

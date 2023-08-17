import Granite
import LemmyKit
import SwiftUI

struct Profile: GraniteComponent {
    @Command var center: Center
    
    @Relay var modal: ModalService
    @Relay var account: AccountService
    
    var pager: Pager<PersonDetailsPageable> = .init(emptyText: "EMPTY_STATE_MISC")
    
    var listeners: Void {
        account
            .center
            .update
            .listen { value in
                if let response = value as? AccountService.Update.ResponseMeta {
                    DispatchQueue.main.async {
                        _state.person.wrappedValue = response.person
                        modal.presentModal(GraniteToastView(response.notification))
                    }
                }
            }
        
        
        account
            .center
            .interact
            .listen(.broadcast) { value in
                if let response = value as? AccountService.Interact.ResponseMeta {
                    switch response.intent {
                    case .removePost(let model):
                        pager.update(item: .init(commentView: nil, postView: model, isMention: false, isReply: false))
                    case .removeComment(let model):
                        //TODO: or censor? w/ restore?
                        pager.remove(item: .init(commentView: model, postView: nil, isMention: false, isReply: false))
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
                    case .editPost(let model):
                        modal.presentSheet {
                            Write(postView: model)
                                .attach({ updatedModel in
                                    DispatchQueue.main.async {
                                        pager.update(item: .init(commentView: nil, postView: updatedModel, isMention: false, isReply: false))
                                        self.modal.dismissSheet()
                                    }
                                }, at: \.updatedPost)
                                .frame(width: Device.isMacOS ? 700 : nil, height: Device.isMacOS ? 500 : nil)
                        }
                    case .editComment(let model):
                        modal.presentSheet {
                            Reply(kind: .editReplyComment(model))
                                .attach({ updatedModel in
                                DispatchQueue.main.async {
                                    pager.update(item: .init(commentView: updatedModel.asView(with: model), postView: nil, isMention: false, isReply: false))
                                    self.modal.dismissSheet()
                                }
                            }, at: \.updateComment)
                            .frame(width: Device.isMacOS ? 600 : nil, height: Device.isMacOS ? 500 : nil)
                        }
                    default:
                        break
                    }
                }
            }
    }
    
    let isMe: Bool
    
    init(_ person: Person? = nil) {
        isMe = person?.isMe == true
        _center = .init(.init(person: person ?? LemmyKit.current.user?.local_user_view.person))
    }
    
    /*
     TODO: mentions/replies
     */
}

public struct PersonDetailsPageable: Pageable {
    var date: Date {
        commentView?.date ?? postView?.date ?? .init()
    }
    
    public var id: String {
        let id = "\(commentView?.id ?? "")\(postView?.id ?? "")"
        if commentView == nil && postView == nil {
            return UUID().uuidString
        } else {
            return id
        }
    }
    
    var blocked: Bool {
        commentView?.blocked == true || postView?.blocked == true
    }
    
    var person: Person {
        (
            commentView?.creator ?? postView?.creator
        ) ?? .mock
    }
    
    let commentView: CommentView?
    let postView: PostView?
    
    var isMention: Bool
    var isReply: Bool
}

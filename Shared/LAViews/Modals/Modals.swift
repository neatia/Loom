//
//  Modals.swift
//  Loom
//
//  Created by PEXAVC on 8/21/23.
//

import Foundation
import SwiftUI
import Granite
import LemmyKit

//MARK: Expand
extension ModalService {
    @MainActor
    func expand(_ postView: PostView?) {
        guard let content = postView?.post.body else { return }
        presentSheet(detents: [.large]) {
            GenericPreview(content: content)
        }
    }
}

//MARK: Report
extension ModalService {
    
    @MainActor
    func showReportModal(_ kind: ReportView.Kind) {
        presentSheet {
            ReportView(kind: kind)
        }
    }
}

//TODO: most of these write based modals could be combined
//MARK: Write {
extension ModalService {
    
    @MainActor
    func showWriteModal(_ model: CommunityView?) {
        presentSheet(detents: [.large]) {
            Write(communityView: model)
                .frame(width: Device.isMacOS ? 600 : nil, height: Device.isMacOS ? 500 : nil)
        }
    }
}

//MARK: Edit {
extension ModalService {
    
    @MainActor
    func showEditPostModal(_ model: PostView?,
                           _ update: ((PostView) -> Void)? = nil) {
        guard let model else {
            //TODO: error toast
            return
        }
        
        presentSheet(detents: [.large]) {
            Write(postView: model)
                .attach({ updatedModel in
                    update?(updatedModel)
                    
                    self.dismissSheet()
                }, at: \.updatedPost)
                .frame(width: Device.isMacOS ? 700 : nil, height: Device.isMacOS ? 500 : nil)
        }
    }
    
    @MainActor
    func showEditCommentModal(_ commentView: CommentView?,
                              postView: PostView? = nil,
                              _ update: ((CommentView) -> Void)? = nil) {
        
        guard let commentView else {
            return
        }
        
        let replyKind: Write.Kind
        
        if let postView {
            replyKind = .editReplyPost(commentView, postView)
        } else {
            replyKind = .editReplyComment(commentView)
        }
        
        presentSheet {
            Reply(kind: replyKind)
                .attach({ model in
                    DispatchQueue.main.async {
                        update?(model)
                        
                        self.dismissSheet()
                    }
                }, at: \.updateComment)
                .frame(width: Device.isMacOS ? 500 : nil, height: Device.isMacOS ? 400 : nil)
        }
    }
}

//MARK: Reply
extension ModalService {
    
    @MainActor
    func showReplyPostModal(model: PostView?,
                            _ update: ((CommentView) -> Void)? = nil) {
        guard let model else {
            return
        }
        
        presentSheet {
            Reply(kind: .replyPost(model))
                .attach({ (model, modelView) in
                    update?(modelView)
                    
                    ModalService.shared.presentModal(GraniteToastView(StandardNotificationMeta(title: "MISC_SUCCESS", message: "ALERT_COMMENT_SUCCESS", event: .success)))
                    
                    ModalService.shared.dismissSheet()
                }, at: \.updatePost)
                .frame(width: Device.isMacOS ? 600 : nil, height: Device.isMacOS ? 500 : nil)
        }
    }
    
    @MainActor
    func showReplyCommentModal(isEditing: Bool,
                               model: CommentView?,
                               _ update: ((CommentView) -> Void)? = nil) {
        guard let model else {
            return
        }
        
        presentSheet {
            Reply(kind: isEditing ? .editReplyComment(model) : .replyComment(model))
                .attach({ replyModel in
                    update?(replyModel)
                    
                    if isEditing {
                        //TODO: edit success modal
                    } else {
                        ModalService.shared.presentModal(GraniteToastView(StandardNotificationMeta(title: "MISC_SUCCESS", message: "ALERT_REPLY_COMMENT_SUCCESS \("@"+model.creator.name)", event: .success)))
                    }
                    
                    ModalService.shared.dismissSheet()
                }, at: \.updateComment)
                .frame(width: Device.isMacOS ? 600 : nil, height: Device.isMacOS ? 500 : nil)
        }
    }
    
}

//MARK: Share
extension ModalService {
    
    @MainActor
    func showShareCommentModal(_ model: CommentView?) {
        presentSheet {
            GraniteStandardModalView(title: "MISC_SHARE", maxHeight: Device.isMacOS ? 600 : nil, fullWidth: Device.isMacOS) {
                ShareModal(urlString: model?.comment.ap_id) {
                    CommentCardView()
                        .frame(width: ContainerConfig.iPhoneScreenWidth * 0.9)
                }
                .contentContext(.init(commentModel: model,
                                      viewingContext: .screenshot))
            }
            .frame(width: Device.isMacOS ? 600 : nil)
            .frame(minHeight: Device.isMacOS ? 500 : nil)
        }
    }
    
    @MainActor
    func showSharePostModal(_ model: PostView?,
                            metadata: PageableMetadata?) {
        presentSheet {
            GraniteStandardModalView(title: "MISC_SHARE", fullWidth: Device.isMacOS) {
                ShareModal(urlString: model?.post.ap_id) {
                    PostCardView()
                        .environment(\.pagerMetadata, metadata)
                        .frame(width: ContainerConfig.iPhoneScreenWidth * 0.9)
                }
                .contentContext(.init(postModel: model,
                                      viewingContext: .screenshot))
            }
            .frame(width: Device.isMacOS ? 600 : nil)
            .frame(minHeight: Device.isMacOS ? 500 : nil)
        }
    }
}

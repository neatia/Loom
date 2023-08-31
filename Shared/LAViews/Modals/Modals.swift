//
//  Modals.swift
//  Loom
//
//  Created by PEXAVC on 8/21/23.
//

import Foundation
import SwiftUI
import Granite
import FederationKit

//MARK: Expand
extension ModalService {
    @MainActor
    func expand(_ postView: FederatedPostResource?) {
        guard let content = postView?.post.body else { return }
        presentSheet(detents: [.medium, .large]) {
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
    func showWriteModal(_ model: FederatedCommunityResource?) {
        presentSheet(detents: [.medium, .large]) {
            Write(communityView: model)
                .frame(width: Device.isMacOS ? 600 : nil, height: Device.isMacOS ? 500 : nil)
        }
    }
}

//MARK: Edit {
extension ModalService {
    
    @MainActor
    func showEditPostModal(_ model: FederatedPostResource?,
                           _ update: ((FederatedPostResource) -> Void)? = nil) {
        guard let model else {
            //TODO: error toast
            return
        }
        
        presentSheet(detents: [.medium, .large]) {
            Write(postView: model)
                .attachAndClear({ updatedModel in
                    update?(updatedModel)
                    
                    self.dismissSheet()
                    
                    //TODO: localize
                    ModalService.shared.presentModal(GraniteToastView(StandardNotificationMeta(title: "MISC_SUCCESS", message: "Post edited", event: .success)))
                }, at: \.updatedPost)
                .frame(width: Device.isMacOS ? 700 : nil, height: Device.isMacOS ? 500 : nil)
        }
    }
    
    @MainActor
    func showEditCommentModal(_ commentView: FederatedCommentResource?,
                              postView: FederatedPostResource? = nil,
                              _ update: ((FederatedCommentResource) -> Void)? = nil) {
        
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
                .attachAndClear({ (updatedModel, replyModel) in
                    update?(updatedModel)
                    self.dismissSheet()
                }, at: \.updateComment)
                .frame(width: Device.isMacOS ? 500 : nil, height: Device.isMacOS ? 400 : nil)
        }
    }
}

//MARK: Reply
extension ModalService {
    
    @MainActor
    func showReplyPostModal(model: FederatedPostResource?,
                            _ update: ((FederatedCommentResource) -> Void)? = nil) {
        guard let model else {
            return
        }
        
        presentSheet {
            Reply(kind: .replyPost(model))
                .attachAndClear({ (model, modelView) in
                    update?(modelView)
                    
                    ModalService
                        .shared
                        .presentModal(
                            GraniteToastView(
                            StandardNotificationMeta(title: "MISC_SUCCESS",
                                                     message: "ALERT_COMMENT_SUCCESS",
                                                     event: .success)
                            )
                        )
                    
                    ModalService.shared.dismissSheet()
                    
                }, at: \.updatePost)
                .frame(width: Device.isMacOS ? 600 : nil, height: Device.isMacOS ? 500 : nil)
        }
    }
    
    @MainActor
    func showReplyCommentModal(isEditing: Bool,
                               model: FederatedCommentResource?,
                               _ update: ((FederatedCommentResource, FederatedCommentResource?) -> Void)? = nil) {
        guard let model else {
            return
        }
        
        presentSheet {
            Reply(kind: isEditing ? .editReplyComment(model) : .replyComment(model))
                .attachAndClear({ (updatedModel, replyModel) in
                    update?(updatedModel, replyModel)
                    
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
    func showShareCommentModal(_ model: FederatedCommentResource?) {
        presentSheet {
            GraniteStandardModalView(title: "MISC_SHARE", fullWidth: Device.isMacOS) {
                ShareModal(urlString: model?.comment.ap_id) {
                    CommentCardView()
                        .frame(width: ContainerConfig.iPhoneScreenWidth * 0.9)
                        .contentContext(.init(commentModel: model,
                                              viewingContext: .screenshot))
                }
            }
            .frame(width: Device.isMacOS ? 600 : nil)
        }
    }
    
    @MainActor
    func showSharePostModal(_ model: FederatedPostResource?,
                            metadata: PageableMetadata?) {
        presentSheet {
            GraniteStandardModalView(title: "MISC_SHARE", fullWidth: Device.isMacOS) {
                ShareModal(urlString: model?.post.ap_id) {
                    PostCardView()
                        .background(Color.background)
                        .environment(\.pagerMetadata, metadata)
                        .frame(width: ContainerConfig.iPhoneScreenWidth * 0.9)
                        .contentContext(.init(postModel: model,
                                              viewingContext: .screenshot))
                }
            }
            .frame(width: Device.isMacOS ? 600 : nil)
        }
    }
}



extension ModalService {
    @MainActor
    func showThreadDrawer(commentView: FederatedCommentResource?,
                          context: ContentContext) {
        presentSheet {
            ThreadView()
                .attach({
                    ModalService.shared.dismissSheet()
                }, at: \.closeDrawer)
                .contentContext(
                    .addCommentModel(model: commentView,
                                     context)
                    .withStyle(.style2)
                    .viewedIn(.thread)
                )
                .frame(width: Device.isMacOS ? 600 : nil, height: Device.isMacOS ? 500 : nil)
        }
    }
}

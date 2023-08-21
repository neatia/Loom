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


//MARK: Reply
extension ModalService {
    
    func showReplyModal(isEditing: Bool,
                        model: CommentView,
                        _ update: @escaping ((CommentView) -> Void)) {
        
        presentSheet {
            Reply(kind: isEditing ? .editReplyComment(model) : .replyComment(model))
                .attach({ replyModel in
                    update(replyModel)
                    
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
    
    func showSharePostModal(_ model: PostView?,
                            metadata: PageableMetadata?) {
        presentSheet {
            GraniteStandardModalView(title: "MISC_SHARE", fullWidth: Device.isMacOS) {
                ShareModal(urlString: model?.post.ap_id) {
                    PostCardView()
                        .environment(\.pagerMetadata, metadata)
                        .frame(width: ContainerConfig.iPhoneScreenWidth * 0.9)
                }
                .environment(\.contentContext, .init(postModel: model,
                                                     viewingContext: .screenshot))
            }
            .frame(width: Device.isMacOS ? 600 : nil)
            .frame(minHeight: Device.isMacOS ? 500 : nil)
        }
    }
}

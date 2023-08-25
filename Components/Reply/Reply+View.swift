import Granite
import SwiftUI
import GraniteUI
import MarkdownView

extension Reply: View {
    public var view: some View {
        VStack(alignment: .leading, spacing: 0) {
            switch kind {
            case .replyPost(let model), .editReplyPost(_, let model):
                HeaderView(showPostActions: false)
                    .padding(.horizontal, .layer3)
                    .padding(.bottom, .layer3)
                    .contentContext(.init(postModel: model))
            case .replyComment(let model),
                    .editReplyComment(let model):
                HeaderView(showPostActions: false)
                    .padding(.horizontal, .layer3)
                    .padding(.bottom, .layer3)
                    .contentContext(.init(commentModel: model))
            default:
                EmptyView()
            }
            
            Divider()
            
            VStack {
                ScrollView(showsIndicators: false) {
                    switch kind {
                    case .replyPost(let model), .editReplyPost(_, let model):
                        if let url = postUrl {
                            HStack {
                                LinkPreview(url: url)
                                    .type(model.post.body == nil ? .large : .small)
                                    .frame(maxWidth: Device.isMacOS ? 400 : ContainerConfig.iPhoneScreenWidth * 0.8)
                                
                                Spacer()
                            }
                            .padding(.horizontal, .layer4)
                            .padding(.top, .layer4)
                        }
                    default:
                        EmptyView()
                    }
                    
                    if let body = postOrCommentContent {
                        MarkdownView(text: body)
                            .markdownViewRole(.editor)
                            .padding(.top, postUrl == nil ? .layer4 : nil)
                            .padding(.bottom, .layer4)
                            .padding(.horizontal, .layer4)
                    }
                }
                .frame(maxHeight: 160)
            }
            .fixedSize(horizontal: false, vertical: true)
            
            Divider()
                .padding(.bottom, Device.isMacOS ? 0 : .layer4)
            
            WriteView(kind: kind, title: .constant(""),
                      content: _state.content)
            
            Divider()
            
            HStack(spacing: .layer3) {
                Spacer()
                
                Button {
                    GraniteHaptic.light.invoke()
                    
                    switch kind {
                    case .replyPost(let model):
                        content.center.interact.send(ContentService.Interact.Meta(kind: .replyPost(model, state.content)))
                    case .replyComment(let model):
                        content.center.interact.send(ContentService.Interact.Meta(kind: .replyComment(model, state.content)))
                    case .editReplyPost(let model, _), .editReplyComment(let model):
                        content.center.interact.send(ContentService.Interact.Meta(kind: .editCommentSubmit(model, state.content)))
                    default:
                        break
                    }
                } label: {
                    Image(systemName: kind.isEditingReply ? "sdcard.fill" : "paperplane.fill")
                        .font(.headline)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .frame(height: 24)
            .padding(.vertical, .layer4)
        }
        .padding(.top, .layer4)
        .background(Device.isIPhone ? .clear : Color.background)
    }
}

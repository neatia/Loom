import Granite
import SwiftUI
import GraniteUI
import MarkdownView

extension Reply: View {
    public var view: some View {
        VStack(alignment: .leading, spacing: 0) {
            if Device.isExpandedLayout || !isPushed {
                headerView
                    .padding(.horizontal, .layer3)
                    .padding(.bottom, .layer4)
                    //Odd visual bug, with the header simply not appearing
                    .frame(minHeight: 1)
            }
            
            Divider()
            
            VStack {
                ScrollView(showsIndicators: false) {
                    switch kind {
                    case .replyPost(let model), .editReplyPost(_, let model):
                        if postOrCommentContent == nil,
                           let url = postUrl {
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
            
            WriteView(kind: kind, title: .constant(""),
                      content: _state.content)
            
            Divider()
            
            HStack(spacing: .layer3) {
                Spacer()
                
                if state.isReplying {
                    StandardProgressView()
                } else {
                    Button {
                        GraniteHaptic.light.invoke()
                        
                        _state.isReplying.wrappedValue = true
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
                            .frame(width: 24, height: 24)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
            }
            .frame(height: 24)
            .padding(.vertical, .layer4)
        }
        .padding(.top, isPushed ? 0 : .layer4)
        .background(Device.isIPhone && !isPushed ? .clear : Color.background)
        .graniteNavigationDestinationIf(isPushed) {
            headerView
                .padding(.leading, .layer4)
        }
    }
}

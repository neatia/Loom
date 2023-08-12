import Granite
import SwiftUI
import GraniteUI

extension Bookmark: View {
    
    @MainActor
    public var view: some View {
        VStack(spacing: 0) {
            if showHeader {
                HStack(spacing: .layer4) {
                    VStack {
                        Spacer()
                        Text("TITLE_BOOKMARKS")
                            .font(.title.bold())
                    }
                    
                    Spacer()
                }
                .frame(height: 36)
                .padding(.top, ContainerConfig.generalViewTopPadding)
                .padding(.leading, .layer4)
                .padding(.trailing, .layer4)
            }
            
            
            HStack(spacing: showHeader == false ? .layer3 : .layer4) {
                Button {
                    GraniteHaptic.light.invoke()
                    _state.kind.wrappedValue = .posts
                } label: {
                    VStack {
                        Spacer()
                        Text("TITLE_POSTS")
                            .font(postsFont)
                            .opacity(postsHeaderOpacity)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Button {
                    GraniteHaptic.light.invoke()
                    _state.kind.wrappedValue = .comments
                } label: {
                    VStack {
                        Spacer()
                        Text("TITLE_COMMENTS")
                            .font(commentsFont)
                            .opacity(commentsHeaderOpacity)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .frame(height: 36)
            .padding(.bottom, showHeader == false ? .layer3 : .layer4)
            .padding(.leading, showHeader == false ? .layer3 :  .layer4)
            .padding(.trailing, showHeader == false ? .layer3 : .layer4)
            
            Divider()
            
            switch state.kind {
            case .posts:
                let postViews = postViews
                LazyScrollView(postViews) { postView in
                    VStack(spacing: 0) {
                        PostCardView(model: postView,
                                     style: .style2,
                                     isCompact: showHeader == false,
                                     linkPreviewType: .largeNoMetadata)
                            .attach({
                                GraniteHaptic.light.invoke()
                                modal.presentSheet {
                                    PostContentView(postView: postView)
                                        .frame(width: Device.isMacOS ? 600 : nil, height: Device.isMacOS ? 500 : nil)
                                }
                            }, at: \.showContent)
                        
                        if postView.id != postViews.last?.id {
                            Divider()
                        }
                    }
                }
            case .comments:
                let commentViews = commentViews
                LazyScrollView(commentViews) { commentView in
                    VStack(spacing: 0) {
                        CommentCardView(model: commentView,
                                        postView: postForComment(commentView),
                                        shouldLinkToPost: true,
                                        isBookmark: true)
                        
                        if commentView.id != commentViews.last?.id {
                            Divider()
                        }
                    }
                }.background(Color.alternateBackground)
            }
        }
        .addGraniteSheet(modal.sheetManager, background: Color.clear)
    }
}

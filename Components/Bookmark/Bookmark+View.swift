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
            
            if bookmarkKeys.isNotEmpty {
                HStack(spacing: .layer4) {
                    Menu {
                        ForEach(bookmarkKeys) { key in
                            Button {
                                GraniteHaptic.light.invoke()
                                switch state.kind {
                                case .posts:
                                    _state.selectedBookmarkPostKey.wrappedValue = key
                                case .comments:
                                    _state.selectedBookmarkCommentKey.wrappedValue = key
                                }
                            } label: {
                                Text(key.description)
                                Image(systemName: "arrow.down.right.circle")
                            }
                        }
                    } label: {
                        switch state.kind {
                        case .posts:
                            Text(state.selectedBookmarkPostKey.description)
                        case .comments:
                            Text(state.selectedBookmarkCommentKey.description)
                        }
                        
#if os(iOS)
                        Image(systemName: "chevron.up.chevron.down")
#endif
                    }
                    .menuStyle(BorderlessButtonMenuStyle())
                    .addHaptic()
                    
                    Spacer()
                }
                .foregroundColor(Device.isMacOS ? .foreground : .accentColor)
                .padding(.vertical, .layer4)
                .padding(.horizontal, showHeader == false ? .layer3 : .layer4)
                
                Divider()
            }
            
            switch state.kind {
            case .posts:
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        postViews()
                    }.padding(.top, 1)
                }
            case .comments:
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        commentViews()
                    }.padding(.top, 1)
                }
                .background(Color.alternateBackground)
            }
        }
        .task {
            _state.selectedBookmarkPostKey.wrappedValue = service.state.posts.keys.first ?? .local
            _state.selectedBookmarkCommentKey.wrappedValue = service.state.comments.keys.first ?? .local
        }
        .addGraniteSheet(modal.sheetManager, background: Color.clear)
    }
    
    func headerView(for host: BookmarkKey) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(host.description)
                    .font(.title3.bold())
                    .foregroundColor(.foreground)
                    .padding(.horizontal, .layer3)
                
                Spacer()
                
            }
            
            Divider().padding(.vertical, .layer4)
        }
        .padding(.top, .layer5)
    }
    
    func postViews(indent: Bool = false) -> some View {
        VStack {
            ForEach(postViews) { postView in
                PostCardView(model: postView,
                             style: .style2,
                             viewingContext: showHeader ? .bookmark(state.selectedBookmarkPostKey.host) : .bookmarkExpanded(state.selectedBookmarkPostKey.host),
                             linkPreviewType: .largeNoMetadata)
                    .attach({ postView in
                        GraniteHaptic.light.invoke()
                        modal.presentSheet {
                            PostContentView(postView: postView)
                                .frame(width: Device.isMacOS ? 600 : nil, height: Device.isMacOS ? 500 : nil)
                        }
                    }, at: \.showContent)
                
                if postView.id != postViews.last?.id {
                    Divider()
                        .padding(.leading, indent ? .layer4 : nil)
                }
            }
        }
    }
    
    func commentViews(indent: Bool = false) -> some View {
        VStack {
            ForEach(commentViews) { commentView in
                CommentCardView(model: commentView,
                                postView: postForComment(commentView),
                                shouldLinkToPost: true,
                                viewingContext: .bookmark(state.selectedBookmarkCommentKey.host))
                
                if commentView.id != commentViews.last?.id {
                    Divider()
                        .padding(.leading, indent ? .layer4 : nil)
                }
            }
        }
    }
}

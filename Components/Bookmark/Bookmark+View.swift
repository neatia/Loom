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
                    
                    Spacer()
                }
                .foregroundColor(Device.isMacOS ? .foreground : .accentColor)
                .padding(.vertical, .layer4)
                .padding(.horizontal, showHeader == false ? .layer3 : .layer4)
                .cancelAnimations()
                //solves weird sizing issue
                .id(state.selectedBookmarkPostKey.description + state.selectedBookmarkCommentKey.description + state.kind.rawValue)
                
                Divider()
            }
            
            switch state.kind {
            case .posts:
                ScrollView(showsIndicators: false) {
                    postCardViews()
                        .padding(.top, 1)
                }
            case .comments:
                ScrollView(showsIndicators: false) {
                    commentCardViews()
                        .padding(.top, 1)
                }
                .background(Color.alternateBackground)
            }
        }
        .task {
            _state.selectedBookmarkPostKey.wrappedValue = service.state.posts.keys.first ?? .local
            _state.selectedBookmarkCommentKey.wrappedValue = service.state.comments.keys.first ?? .local
        }
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
    
    func postCardViews() -> some View {
        LazyVStack(spacing: 0) {
            ForEach(postViews) { postView in
                PostCardView(topPadding: postViews.first?.id == postView.id ? .layer5 : .layer6,
                             linkPreviewType: .largeNoMetadata)
                    .contentContext(.init(postModel: postView,
                                          viewingContext: showHeader ? .bookmark(state.selectedBookmarkPostKey.host) : .bookmarkExpanded(state.selectedBookmarkPostKey.host)))
                
                
                if postView.id != postViews.last?.id {
                    Divider()
                }
            }
        }
    }
    
    func commentCardViews() -> some View {
        LazyVStack(spacing: 0) {
            ForEach(commentViews) { commentView in
                CommentCardView(context: .init(postModel: postForComment(commentView),
                                               commentModel: commentView,
                                               preferredFeedStyle: .style2,
                                               viewingContext: .bookmark(state.selectedBookmarkCommentKey.host)),
                                shouldLinkToPost: true)
                
                if commentView.id != commentViews.last?.id {
                    Divider()
                }
            }
        }
    }
}

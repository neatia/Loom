import Granite
import GraniteUI
import SwiftUI
import LemmyKit

extension Profile: GraniteNavigationDestination {
    public var view: some View {
        VStack(spacing: 0) {
            PagerScrollView(PersonDetailsPageable.self,
                            properties: .init(alternateContentPosition: true)) {
                inlineView
            } inlineBody: {
                titleBarView
            } content: { details in
                if let model = details.commentView,
                   !filterOverviewPosts {
                    CommentCardView()
                        .graniteEvent(account.center.interact)
                        .contentContext(.init(commentModel: model,
                                              viewingContext: details.isReply || details.isMention ? .base : .profile))
                } else if let model = details.postView,
                          !filterOverviewComments {
                    PostCardView()
                        .graniteEvent(account.center.interact)
                        .contentContext(.init(postModel: model, viewingContext: .profile))
                    
                }
            }
            .environmentObject(pager)
        }
        .padding(.top, Device.isMacOS ? .layer5 : 0)
        //TODO: Negative space from transparent titlebar. (Need to investigate why I needed to resolve this again vs. PostDisplayView and other cases with the same layout/enviornment)
        .overlayIf(Device.isMacOS, alignment: .top) { Color.background.frame(maxWidth: .infinity).frame(height: 28) }
        .background(Color.background)
        .task {
            pager.hook { page in
                switch state.viewingDataType {
                case .overview:
                    let details = await Lemmy.details(state.person,
                                                      sort: .new,
                                                      page: page,
                                                      limit: ConfigService.Preferences.pageLimit,
                                                      community: nil,
                                                      saved_only: nil,
                                                      location: state.person?.isMe == true ? .base : .source)
                    
                    var models: [any Pageable] = (details?.comments ?? []) + (details?.posts ?? [])
                    models = models.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
                    
                    let overview = models.map {
                        PersonDetailsPageable(commentView: $0 as? CommentView, postView: $0 as? PostView, isMention: false, isReply: false)
                    }
                    return overview
                case .mentions:
                    
                    let mentionDetails = await Lemmy.mentions(sort: .new, page: page, limit: ConfigService.Preferences.pageLimit, unreadOnly: nil)
                    
                    let mentions = mentionDetails?.mentions.compactMap {
                        PersonDetailsPageable(commentView: $0.asCommentView, postView: nil, isMention: true, isReply: false)
                    } ?? []
                    
                    return mentions
                case .replies:
                    let replyDetails = await Lemmy.replies(sort: .new, page: page, limit: ConfigService.Preferences.pageLimit, unreadOnly: nil)
                    
                    let replies = replyDetails?.replies.compactMap {
                        PersonDetailsPageable(commentView: $0.asCommentView, postView: nil, isMention: false, isReply: true)
                    } ?? []
                    
                    return replies
                }
            }.fetch()
        }
    }
    
    var destinationStyle: GraniteNavigationDestinationStyle {
        return .init(navBarBGColor: Color.background)
    }
}

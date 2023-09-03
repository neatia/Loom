import Granite
import GraniteUI
import SwiftUI
import FederationKit

extension Profile: GraniteNavigationDestination {
    public var view: some View {
        VStack(spacing: 0) {
            PagerScrollView(PersonDetailsPageable.self,
                            properties: .init(alternateContentPosition: true,
                                              partition: Device.isMacOS == false,
                                              lazy: false)) {
                inlineView
            } inlineBody: {
                titleBarView
            } content: { details in
                if let model = details.commentView,
                   !filterOverviewPosts {
                    CommentCardView(context: .init(commentModel: model,
                                                   viewingContext: details.isReply || details.isMention ? .base : .profile))
                        .graniteEvent(account.center.interact)
                } else if let model = details.postView,
                          !filterOverviewComments {
                    PostCardView()
                        .graniteEvent(account.center.interact)
                        .contentContext(.init(postModel: model, viewingContext: .profile))
                    
                }
            }
            .environmentObject(pager)
        }
        .background(Color.background)
        .task {
            pager.hook { page in
                switch state.viewingDataType {
                case .overview:
                    let details = await Federation.person(state.person,
                                                      sort: .new,
                                                      page: page,
                                                      limit: ConfigService.Preferences.pageLimit,
                                                      community: nil,
                                                      saved_only: nil,
                                                      //Probably why a community is accepted to target that actor_id when fetching person details instead of the person actor id
                                                      //Should this just be always the source?
                                                      location: profileFetchLocation)
                    
                    var models: [any Pageable] = (details?.comments ?? []) + (details?.posts ?? [])
                    
                    let overview = models.map {
                        PersonDetailsPageable(commentView: $0 as? FederatedCommentResource, postView: $0 as? FederatedPostResource, isMention: false, isReply: false)
                    }
                    
                    return overview.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
                case .mentions:
                    
                    let mentionDetails = await Federation.mentions(sort: .new, page: page, limit: ConfigService.Preferences.pageLimit, unreadOnly: nil)
                    
                    let mentions = mentionDetails?.mentions.compactMap {
                        PersonDetailsPageable(commentView: $0.asCommentResource, postView: nil, isMention: true, isReply: false)
                    } ?? []
                    
                    return mentions
                case .replies:
                    let replyDetails = await Federation.replies(sort: .new, page: page, limit: ConfigService.Preferences.pageLimit, unreadOnly: nil)
                    
                    let replies = replyDetails?.replies.compactMap {
                        PersonDetailsPageable(commentView: $0.asCommentResource, postView: nil, isMention: false, isReply: true)
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

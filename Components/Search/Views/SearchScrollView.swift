//
//  SearchScrollView.swift
//  Loom
//
//  Created by PEXAVC on 7/25/23.
//

import Foundation
import Granite
import GraniteUI
import SwiftUI
import Combine
import LemmyKit

struct SearchScrollView: View {
    var query: String
    @Binding var response: SearchResponse?
    
    @StateObject var pagerPosts: Pager<PostView> = .init(emptyText: "EMPTY_STATE_NO_POSTS")
    @StateObject var pagerComments: Pager<CommentView> = .init(emptyText: "EMPTY_STATE_NO_COMMENTS")
    @StateObject var pagerUsers: Pager<PersonView> = .init(emptyText: "EMPTY_STATE_NO_USERS")
    @StateObject var pagerCommunities: Pager<CommunityView> = .init(emptyText: "EMPTY_STATE_NO_COMMUNITIES")
    
    var searchType: SearchType
    var community: Community?
    
    var selectedSort: SortType
    var selectedListing: ListingType
    
    init(_ searchType: SearchType,
         community: Community?,
         sortType: SortType,
         listingType: ListingType,
         response: Binding<SearchResponse?>,
         query: String) {
        self.searchType = searchType
        self.community = community
        self.selectedSort = sortType
        self.selectedListing = listingType
        self._response = response
        self.query = query
    }
    
    var body: some View {
        VStack(spacing: 0) {
            switch searchType {
            case .posts:
                PagerScrollView(PostView.self) {
                    headerView
                } inlineBody: {
                    EmptyView()
                } content: { model in
                    PostCardView(model: model)
                        .attach({
                            GraniteHaptic.light.invoke()
                            //                    modal.presentSheet {
                            //                        PostContentView(postView: postView)
                            //                            .frame(width: Device.isMacOS ? 600 : nil, height: Device.isMacOS ? 500 : nil)
                            //                    }
                        }, at: \.showContent)
                }.environmentObject(pagerPosts)
            case .communities:
                PagerScrollView(CommunityView.self) {
                    headerView
                } inlineBody: {
                    EmptyView()
                } content: { model in
                    CommunityCardView(model: model, fullWidth: true)
                        .padding(.layer4)
                }.environmentObject(pagerCommunities)
            case .comments:
                PagerScrollView(CommentView.self) {
                    headerView
                } inlineBody: {
                    EmptyView()
                } content: { model in
                    CommentCardView(model: model)
                }.environmentObject(pagerComments)
            case .users:
                PagerScrollView(PersonView.self) {
                    headerView
                } inlineBody: {
                    EmptyView()
                } content: { model in
                    UserCardView(model: model, fullWidth: true)
                        .padding(.layer4)
                }.environmentObject(pagerUsers)
            default:
                EmptyView()
            }
        }
        .task {
            setInitial()
            switch searchType {
            case .posts:
                pagerPosts.hook { page in
                    (await search(page))?.posts ?? []
                }
            case .communities:
                pagerCommunities.hook { page in
                    (await search(page))?.communities ?? []
                }
            case .comments:
                pagerComments.hook { page in
                    (await search(page))?.comments ?? []
                }
            case .users:
                pagerUsers.hook { page in
                    (await search(page))?.users ?? []
                }
            default:
                break
            }
        }.onChange(of: response) { _ in
            setInitial()
        }
    }
    
    func setInitial() {
        switch searchType {
        case .posts:
            let pageIndex = response?.posts.isEmpty == true ? 1 : 2
            pagerPosts.add(response?.posts ?? [], pageIndex: pageIndex)
        case .comments:
            let pageIndex = response?.comments.isEmpty == true ? 1 : 2
            pagerComments.add(response?.comments ?? [], pageIndex: pageIndex)
        case .users:
            let pageIndex = response?.users.isEmpty == true ? 1 : 2
            pagerUsers.add(response?.users ?? [], pageIndex: pageIndex)
        case .communities:
            let pageIndex = response?.communities.isEmpty == true ? 1 : 2
            pagerCommunities.add(response?.communities ?? [], pageIndex: pageIndex)
        default:
            break
        }
    }
    
    func search(_ page: Int?) async -> SearchResponse? {
        return  await Lemmy.search(query,
                                   type_: searchType,
                                   communityId: nil,
                                   communityName: community?.name,
                                   creatorId: nil,
                                   sort: selectedSort,
                                   listingType: selectedListing,
                                   page: page,
                                   limit: ConfigService.Preferences.pageLimit)
    }
    
    var headerView: some View {
        HStack(spacing: .layer4) {
            VStack {
                Spacer()
                Text("\(searchType.rawValue.capitalized)")
                    .font(.title.bold())
            }
            
            Spacer()
        }
        .frame(height: 36)
        .padding(.top, .layer4)
        .padding(.bottom, .layer3)
        .padding(.horizontal, .layer4)
        .background(Color.alternateBackground)
    }
}

extension SearchType {
    var isFocusedContent: Bool {
        switch self {
        case .users, .comments, .communities, .posts:
            return true
        default:
            return false
        }
    }
}

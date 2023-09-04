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
import FederationKit

struct SearchScrollView: View {
    @Binding var query: String
    @Binding var response: FederatedSearchResult?
    
    @StateObject var pagerPosts: Pager<FederatedPostResource> = .init(emptyText: "EMPTY_STATE_NO_POSTS")
    @StateObject var pagerComments: Pager<FederatedCommentResource> = .init(emptyText: "EMPTY_STATE_NO_COMMENTS")
    @StateObject var pagerUsers: Pager<FederatedPersonResource> = .init(emptyText: "EMPTY_STATE_NO_USERS")
    @StateObject var pagerCommunities: Pager<FederatedCommunityResource> = .init(emptyText: "EMPTY_STATE_NO_COMMUNITIES")
    
    var searchType: FederatedSearchType
    var community: FederatedCommunity?
    
    var selectedSort: FederatedSortType
    var selectedListing: FederatedListingType
    
    init(_ searchType: FederatedSearchType,
         community: FederatedCommunity?,
         sortType: FederatedSortType,
         listingType: FederatedListingType,
         response: Binding<FederatedSearchResult?>,
         query: Binding<String>) {
        self.searchType = searchType
        self.community = community
        self.selectedSort = sortType
        self.selectedListing = listingType
        self._response = response
        self._query = query
    }
    
    var body: some View {
        VStack(spacing: 0) {
            switch searchType {
            case .posts:
                PagerScrollView(FederatedPostResource.self) {
                    headerView
                } inlineBody: {
                    EmptyView()
                } content: { model in
                    PostCardView()
                        .contentContext(.init(postModel: model))
                }.environmentObject(pagerPosts)
            case .communities:
                PagerScrollView(FederatedCommunityResource.self) {
                    headerView
                } inlineBody: {
                    EmptyView()
                } content: { model in
                    //TODO: handle expanded layout response
                    CommunityCardView(model: model,
                                      shouldRoute: true,
                                      fullWidth: true)
                        .padding(.layer4)
                }.environmentObject(pagerCommunities)
            case .comments:
                PagerScrollView(FederatedCommentResource.self) {
                    headerView
                } inlineBody: {
                    EmptyView()
                } content: { model in
                    CommentCardView(context: .init(commentModel: model))
                }.environmentObject(pagerComments)
            case .users:
                PagerScrollView(FederatedPersonResource.self) {
                    headerView
                } inlineBody: {
                    EmptyView()
                } content: { model in
                    UserCardView(model: model, fullWidth: true, showCounts: true, style: .style2)
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
        LoomLog("🔎 initial set | \(response?.posts.count ?? 0) posts 🔎", level: .debug)
        let pageIndexPosts = response?.posts.isEmpty == true ? 1 : 2
        pagerPosts.add(response?.posts ?? [], pageIndex: pageIndexPosts, initialFetch: false)
        LoomLog("🔎 initial set | \(response?.comments.count ?? 0) comments 🔎", level: .debug)
        let pageIndexComments = response?.comments.isEmpty == true ? 1 : 2
        pagerComments.add(response?.comments ?? [], pageIndex: pageIndexComments, initialFetch: false)
        LoomLog("🔎 initial set | \(response?.users.count ?? 0) users 🔎", level: .debug)
        let pageIndexUsers = response?.users.isEmpty == true ? 1 : 2
        pagerUsers.add(response?.users ?? [], pageIndex: pageIndexUsers, initialFetch: false)
        LoomLog("🔎 initial set | \(response?.communities.count ?? 0) communities 🔎", level: .debug)
        let pageIndexCommunities = response?.communities.isEmpty == true ? 1 : 2
        pagerCommunities.add(response?.communities ?? [], pageIndex: pageIndexCommunities, initialFetch: false)
    }
    
    func search(_ page: Int?) async -> FederatedSearchResult? {
        LoomLog("🔎 requesting new page: \(page ?? -1) 🔎", level: .debug)
        return  await Federation.search(query,
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

extension FederatedSearchType {
    var isFocusedContent: Bool {
        switch self {
        case .users, .comments, .communities, .posts:
            return true
        default:
            return false
        }
    }
}

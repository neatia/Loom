//
//  Comment.swift
//  Loom
//
//  Created by PEXAVC on 7/28/23.
//

import Foundation
import FederationKit

extension FederatedCommentResource: Pageable {
    public var date: Date {
        return (
            self.comment.updated ?? self.comment.published
        ).serverTimeAsDate ?? Date()
    }
    
    public var blocked: Bool {
        creator_blocked
    }
    
    public var person: FederatedPerson {
        creator
    }
    
    public var isAdmin: Bool {
        self.person.admin
    }
    
    public var shouldHide: Bool {
        let shouldHideNSFW: Bool = (self.post.nsfw == true || self.community.nsfw == true) && PagerFilter.enableForNSFW
        
        let shouldHideKeywords: Bool
        if PagerFilter.enableForKeywords {
            shouldHideKeywords = PagerFilter.filterKeywords.check(comment: self)
        } else {
            shouldHideKeywords = false
        }
        
        return shouldHideNSFW || shouldHideKeywords
    }
}

extension FederatedCommentResource {
    func updateBlock(_ blocked: Bool, personView: FederatedPersonResource) -> FederatedCommentResource {
        .init(comment: self.comment, creator: personView.person, post: self.post, community: self.community, counts: self.counts, creator_banned_from_community: self.creator_banned_from_community, subscribed: self.subscribed, saved: self.saved, creator_blocked: blocked)
    }
    
    func updateRemoved() -> FederatedCommentResource {
        .init(comment: self.comment.updateRemoved(), creator: self.person, post: self.post, community: self.community, counts: self.counts, creator_banned_from_community: self.creator_banned_from_community, subscribed: self.subscribed, saved: self.saved, creator_blocked: blocked)
    }
    
    func updateDeleted() -> FederatedCommentResource {
        .init(comment: self.comment.updateDeleted(),
              creator: self.person,
              post: self.post,
              community: self.community,
              counts: self.counts,
              creator_banned_from_community: self.creator_banned_from_community,
              subscribed: self.subscribed,
              saved: self.saved,
              creator_blocked: self.blocked,
              my_vote: self.my_vote)
    }
}

extension FederatedCommentResource: Identifiable {
    public var md5: String {
        let compiled = comment.content
        return compiled.md5()
    }
}


extension FederatedComment {
    func asView(creator: FederatedPerson, postView: FederatedPostResource) -> FederatedCommentResource {
        .init(comment: self, creator: creator, post: postView.post, community: postView.community, counts: .new(commentId: self.id, published: self.published), creator_banned_from_community: postView.creator_banned_from_community, subscribed: postView.subscribed, saved: false, creator_blocked: false)
    }
    
    func asView(creator: FederatedPerson,
                post: FederatedPost,
                community: FederatedCommunity) -> FederatedCommentResource {
        .init(comment: self,
              creator: creator,
              post: post,
              community: community,
              counts: .new(commentId: self.id, published: self.published),
              //Thiss can be inconsistent, but since its from replies its highly unlikely
              creator_banned_from_community: false,
              //This can be inconsistent
              subscribed: .notSubscribed,
              saved: false,
              creator_blocked: false)
    }
    
    func asView(with model: FederatedCommentResource) -> FederatedCommentResource {
        .init(comment: self, creator: model.creator, post: model.post, community: model.community, counts: model.counts, creator_banned_from_community: model.creator_banned_from_community, subscribed: model.subscribed, saved: model.saved, creator_blocked: model.creator_blocked)
    }
    
    func updateRemoved() -> FederatedComment {
        .init(id: self.id,
              creator_id: self.creator_id,
              post_id: self.post_id,
              content: self.content,
              removed: !self.removed,
              published: self.published,
              updated: self.updated,
              deleted: self.deleted,
              ap_id: self.ap_id,
              local: self.local,
              path: self.path,
              distinguished: self.distinguished,
              language_id: self.language_id,
              instanceType: self.instanceType)
    }
    
    func updateDeleted() -> FederatedComment {
        .init(id: self.id,
              creator_id: self.creator_id,
              post_id: self.post_id,
              content: self.content,
              removed: self.removed,
              published: self.published,
              updated: self.updated,
              deleted: !self.deleted,
              ap_id: self.ap_id,
              local: self.local,
              path: self.path,
              distinguished: self.distinguished,
              language_id: self.language_id,
              instanceType: self.instanceType)
    }
}

extension FederatedCommentAggregates {
    static func new(id: String = "-1", commentId: String, published: String) -> FederatedCommentAggregates {
        .init(id: id, comment_id: commentId, score: 1, upvotes: 1, downvotes: 0, published: published, child_count: 0, hot_rank: 0)
    }
    
    func incrementReplyCount() -> FederatedCommentAggregates {
        .init(id: self.id, comment_id: self.comment_id, score: self.score, upvotes: self.upvotes, downvotes: self.downvotes, published: self.published, child_count: self.child_count + 1, hot_rank: self.hot_rank)
    }
}

extension FederatedCommentResource {
    func incrementReplyCount() -> FederatedCommentResource {
        .init(comment: self.comment, creator: self.creator, post: self.post, community: self.community, counts: self.counts.incrementReplyCount(), creator_banned_from_community: self.creator_banned_from_community, subscribed: self.subscribed, saved: self.saved, creator_blocked: self.creator_blocked)
    }
}

//
//  TweetViewCellTrailingFooter.swift
//  TonyStark
//
//  Created by Mohammed Sadiq on 19/04/22.
//

import UIKit

extension PartialTweetTableViewCell.Trailing {
    class Footer: TXView {
        // Declare
        private let likeInteractionDetails: LikeInteractionDetails = {
            let likeInteractionDetails = LikeInteractionDetails()
            
            likeInteractionDetails.enableAutolayout()
            likeInteractionDetails.fixHeight(to: 20)
            
            return likeInteractionDetails
        }()
        
        private let commentInteractionDetails: CommentInteractionDetails = {
            let commentInteractionDetails = CommentInteractionDetails()
            
            commentInteractionDetails.enableAutolayout()
            commentInteractionDetails.fixHeight(to: 20)
            
            return commentInteractionDetails
        }()
        
        private let tweetOptions: PartialTweetOptions = {
            let tweetOptions = PartialTweetOptions()
            
            tweetOptions.enableAutolayout()
            tweetOptions.fixHeight(to: 20)
            
            return tweetOptions
        }()
        
        // Arrange
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            arrangeSubviews()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func arrangeSubviews() {
            let combinedStackView = makeCombinedStackView()
            
            addSubview(combinedStackView)
            
            combinedStackView.pin(to: self)
        }
        
        private func makeCombinedStackView() -> TXStackView {
            let combinedStack = TXStackView(
                arrangedSubviews: [
                    likeInteractionDetails,
                    commentInteractionDetails,
                    tweetOptions,
                ]
            )
            
            combinedStack.enableAutolayout()
            combinedStack.axis = .horizontal
            combinedStack.spacing = 16
            combinedStack.distribution = .fillEqually
            combinedStack.alignment = .center
            
            return combinedStack
        }
        
        // Configure
        @available(iOS 14, *)
        func configure(
            withTweet tweet: Tweet,
            onLikePressed: @escaping () -> Void,
            onCommentPressed: @escaping () -> Void,
            onBookmarkPressed: @escaping () -> Void,
            onFollowPressed: @escaping () -> Void,
            onDeletePressed: @escaping () -> Void
        ) {
            likeInteractionDetails.configure(
                withTweet: tweet,
                onLikePressed: onLikePressed
            )
            
            commentInteractionDetails.configure(
                withTweet: tweet,
                onCommentPressed: onCommentPressed
            )
            
            tweetOptions.configure(
                withTweet: tweet,
                onBookmarkPressed: onBookmarkPressed,
                onFollowPressed: onFollowPressed,
                onDeletePressed: onDeletePressed
            )
        }
        
        @available(iOS, deprecated: 14)
        func configure(
            withTweet tweet: Tweet,
            onLikePressed: @escaping () -> Void,
            onCommentPressed: @escaping () -> Void,
            onOptionsPressed: @escaping () -> Void
        ) {
            likeInteractionDetails.configure(
                withTweet: tweet,
                onLikePressed: onLikePressed
            )
            
            commentInteractionDetails.configure(
                withTweet: tweet,
                onCommentPressed: onCommentPressed
            )
            
            tweetOptions.configure(
                onOptionsPressed: onOptionsPressed
            )
        }
    }
}

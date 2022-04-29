//
//  CurrentUserDetailsTableViewCellFooter.swift
//  TonyStark
//
//  Created by Mohammed Sadiq on 18/04/22.
//

import UIKit

class CurrentUserTableViewCellFooter: TXView {
    private enum SocialDetailsIdentifier: String {
        case followers = "follower"
        case followings = "followings"
    }
    
    // Declare
    private let followersSocialDetails: SocialDetails = {
        let followersSocialDetails = SocialDetails()
        
        followersSocialDetails.identifier = SocialDetailsIdentifier.followers.rawValue
        
        followersSocialDetails.enableAutolayout()
        
        return followersSocialDetails
    }()
    
    private let followingsSocialDetails: SocialDetails = {
        let followingsSocialDetails = SocialDetails()
        
        followingsSocialDetails.identifier = SocialDetailsIdentifier.followings.rawValue
        
        followingsSocialDetails.enableAutolayout()
        
        return followingsSocialDetails
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
                followersSocialDetails,
                followingsSocialDetails,
                TXStackView.spacer,
            ]
        )
        
        combinedStack.enableAutolayout()
        combinedStack.axis = .horizontal
        combinedStack.spacing = 8
        combinedStack.distribution = .fill
        combinedStack.alignment = .center
        
        return combinedStack
    }
    
    // Configure
    func configure(
        withUser user: User,
        onFollowersPressed: @escaping () -> Void,
        onFollowingsPressed: @escaping () -> Void
    ) {
        followersSocialDetails.configure(
            withData: (
                leadingText: "\(user.socialDetails.followersCount)",
                trailingText: "Followers"
            ),
            onPressed: onFollowersPressed
        )
        
        followingsSocialDetails.configure(
            withData: (
                leadingText: "\(user.socialDetails.followingsCount)",
                trailingText: "Followings"
            ),
            onPressed: onFollowingsPressed
        )
    }
}

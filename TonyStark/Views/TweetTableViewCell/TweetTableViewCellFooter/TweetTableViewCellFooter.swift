//
//  PartialUserTableViewCellFooter.swift
//  TonyStark
//
//  Created by Mohammed Sadiq on 25/04/22.
//

import UIKit

class TweetTableViewCellFooter: TXView {
    // Declare
    private let header: TweetTableViewCellFooterHeader = {
        let header = TweetTableViewCellFooterHeader()
        
        header.enableAutolayout()
        
        return header
    }()
    
    private let footer: TweetTableViewCellFooterFooter = {
        let footer = TweetTableViewCellFooterFooter()
        
        footer.enableAutolayout()
        
        return footer
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
                header,
                footer
            ]
        )
        
        combinedStack.enableAutolayout()
        combinedStack.axis = .vertical
        combinedStack.distribution = .equalSpacing
        combinedStack.alignment = .leading
        combinedStack.spacing = 8
        
        return combinedStack
    }
    
    // Configure
    func configure(
        withTweet tweet: Tweet,
        onLikePressed: @escaping () -> Void
    ) {
        header.configure(withTweet: tweet)
        footer.configure(
            withTweet: tweet,
            onPressed: onLikePressed
        )
    }
    
    // Interact
}


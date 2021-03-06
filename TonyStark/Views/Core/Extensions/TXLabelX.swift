//
//  TXLabel.swift
//  TonyStark
//
//  Created by Mohammed Sadiq on 29/04/22.
//

import UIKit

extension TXLabel {
    static func name() -> TXLabel {
        let nameText = TXLabel()
        
        nameText.font = .systemFont(ofSize: 16, weight: .bold)
        nameText.textColor = .label
        nameText.adjustsFontSizeToFitWidth = false
        
        return nameText
    }
    
    static func username() -> TXLabel {
        let usernameText = TXLabel()

        usernameText.font = .systemFont(ofSize: 16, weight: .regular)
        usernameText.textColor = .secondaryLabel
        usernameText.adjustsFontSizeToFitWidth = false
        
        return usernameText
    }
    
    static func bio() -> TXLabel {
        let bioText = TXLabel()
        
        bioText.numberOfLines = 0
        bioText.font = .systemFont(ofSize: 16, weight: .regular)
        bioText.textColor = .label
        bioText.adjustsFontSizeToFitWidth = false
        
        return bioText
    }
    
    static func sepator() -> TXLabel {
        let sepator = TXLabel()

        sepator.font = .systemFont(ofSize: 16, weight: .regular)
        sepator.textColor = .secondaryLabel
        sepator.adjustsFontSizeToFitWidth = false
        
        return sepator
    }
    
    static func dateTime() -> TXLabel {
        let usernameText = TXLabel()

        usernameText.font = .systemFont(ofSize: 16, weight: .regular)
        usernameText.lineBreakMode = .byTruncatingTail
        usernameText.textColor = .secondaryLabel
        usernameText.adjustsFontSizeToFitWidth = false
        
        return usernameText
    }
    
    static func tweet() -> TXLabel {
        let tweetText = TXLabel()
        
        tweetText.font = .systemFont(ofSize: 16, weight: .regular)
        tweetText.textColor = .label
        tweetText.numberOfLines = 0
        tweetText.adjustsFontSizeToFitWidth = false
        
        return tweetText
    }
    
    static func comment() -> TXLabel {
        let commentText = TXLabel()
        
        commentText.font = .systemFont(ofSize: 16, weight: .regular)
        commentText.textColor = .label
        commentText.numberOfLines = 0
        commentText.adjustsFontSizeToFitWidth = false
        
        return commentText
    }
}

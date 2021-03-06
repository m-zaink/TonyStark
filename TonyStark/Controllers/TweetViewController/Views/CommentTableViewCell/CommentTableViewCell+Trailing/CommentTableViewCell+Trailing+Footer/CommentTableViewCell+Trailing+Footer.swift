//
//  CommentTableViewCell+Trailing+Footer.swift
//  TonyStark
//
//  Created by Mohammed Sadiq on 06/06/22.
//

import UIKit

extension CommentTableViewCell.Trailing {
    class Footer: TXView {
        // Declare
        let dateText: TXLabel = {
            let dateText: TXLabel = .dateTime()
            
            dateText.enableAutolayout()
            
            return dateText
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
            addSubview(dateText)
            
            dateText.pin(to: self)
        }
        
        // Configure
        func configure(withComment comment: Comment) {
            dateText.text = comment.creationDate.formatted(as: .visiblyPleasingShort)
        }
        
        // Interact
    }
}

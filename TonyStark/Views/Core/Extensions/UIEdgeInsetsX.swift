//
//  UIEdgeInsets.swift
//  TonyStark
//
//  Created by Mohammed Sadiq on 22/04/22.
//

import UIKit

extension UIEdgeInsets {
    static var empty: UIEdgeInsets {
        get {
            return UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 0,
                right: 0
            )
        }
    }
    
    static func all(_ inset: Double) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: inset,
            left: inset,
            bottom: -inset,
            right: -inset
        )
    }
    
    static func leading(_ inset: Double) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: 0,
            left: inset,
            bottom: 0,
            right: 0
        )
    }
    
    static func trailing(_ inset: Double) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 0,
            right: -inset
        )
    }
    
    static func top(_ inset: Double) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: inset,
            left: 0,
            bottom: 0,
            right: 0
        )
    }
    
    static func bottom(_ inset: Double) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: -inset,
            right: 0
        )
    }
    
    static func horizontallySymmetric(_ inset: Double) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: 0,
            left: inset,
            bottom: 0,
            right: -inset
        )
    }
    
    static func verticallySymmetric(_ inset: Double) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: inset,
            left: 0,
            bottom: -inset,
            right: 0
        )
    }
    
    static func symmetric(
        horizontal horizontalInset: Double = 0,
        vertical verticalInset: Double = 0
    ) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: -verticalInset,
            right: -horizontalInset
        )
    }
}

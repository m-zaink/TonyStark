//
//  Response.swift
//  TonyStark
//
//  Created by Mohammed Sadiq on 03/05/22.
//

import Foundation

// MARK: Log In
enum LogInFailure: Error {
    case unknown
}

// MARK: Log Out
enum LogOutFailure: Error {
    case unknown
}

// MARK: Edit User
enum UpdateUserFailure: Error {
    case unknown
    case usernameUnavailable
}

// MARK: Refresh user
enum RefreshUserFailure: Error {
    case unknown
}

// MARK: UserFailure
enum UserFailure: Error {
    case unknown
}

// MARK: CreateTokenFailure
enum CreateTokenFailure: Error {
    case unknown
}

// MARK: DeleteTokenFailure
enum DeleteTokenFailure: Error {
    case unknown
}

//
//  FeedDataStore.swift
//  TonyStark
//
//  Created by Mohammed Sadiq on 03/05/22.
//

import Foundation

class FeedDataStore: DataStore {
    static let shared = FeedDataStore()
    
    private init() { }
    
    func bootUp() async {
        // Do nothing
    }
    
    func bootDown() async {
        // Do nothing
    }

   
    func feed(
        after nextToken: String? = nil
    ) async -> Result<Paginated<Tweet>, FeedFailure> {
        return .failure(.unknown)
    }
}

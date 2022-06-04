//
//  SearchDataStore.swift
//  TonyStark
//
//  Created by Mohammed Sadiq on 29/04/22.
//

import Foundation

protocol SearchDataStoreProtocol: DataStoreProtocol {
    func search(withKeyword keyword: String) async -> Result<Paginated<User>, SearchFailure>
    
    func search(
        withKeyword keyword: String,
        after nextToken: String
    ) async -> Result<Paginated<User>, SearchFailure>

    func previousSearchKeywords() async -> Result<[String], PreviousSearchKeywordsFailure>
}

class SearchDataStore: SearchDataStoreProtocol {
    static let shared: SearchDataStoreProtocol = SearchDataStore()
    
    private static let keywordsStorageKey = "keywordsStorageKey"
    
    private init() { }
    
    func bootUp() async {
        // Do nothing
    }
    
    func bootDown() async {
        // Do nothing
    }
    
    func search(withKeyword keyword: String) async -> Result<Paginated<User>, SearchFailure> {
        return await paginatedSearch(withKeyword: keyword, after: nil)
    }
    
    func search(
        withKeyword keyword: String,
        after nextToken: String
    ) async -> Result<Paginated<User>, SearchFailure> {
        return await paginatedSearch(withKeyword: keyword, after: nextToken)
    }
    
    func paginatedSearch(
        withKeyword keyword: String,
        after nextToken: String?
    ) async -> Result<Paginated<User>, SearchFailure> {
        await captureKeyword(keyword)
        
        let paginated: Paginated<User> = await withCheckedContinuation {
            continuation in
            
            DispatchQueue
                .global(qos: .background)
                .asyncAfter(deadline: .now()) {
                    let users: [User] = [
                        User(
                            id: "sadiyakhan",
                            name: "Sadiya Khan",
                            email: "sadiya@gmail.com",
                            username: "sadiyakhan",
                            image: "https://www.mirchi9.com/wp-content/uploads/2022/02/Mahesh-Fans-Firing-on-Pooja-Hegde.jpg",
                            description: """
                            I'm simple and soft.
                            """,
                            creationDate: .now(),
                            lastUpdatedDate: .now(),
                            socialDetails: User.SocialDetails(
                                followersCount: 0,
                                followeesCount: 0
                            ),
                            activityDetails: User.ActivityDetails(
                                tweetsCount: 0
                            ),
                            viewables: User.Viewables(
                                following: false
                            )
                        ),
                        User(
                            id: "mzaink",
                            name: "Zain Khan",
                            email: "zain@gmail.com",
                            username: "mzaink",
                            image: "https://pbs.twimg.com/profile_images/1483797876522512385/9CcO904A_400x400.jpg",
                            description: """
                            Hungry for knowledge. Satiated with life. ✌️
                            """,
                            creationDate: .now(),
                            lastUpdatedDate: .now(),
                            socialDetails: User.SocialDetails(
                                followersCount: 0,
                                followeesCount: 0
                            ),
                            activityDetails: User.ActivityDetails(
                                tweetsCount: 0
                            ),
                            viewables: User.Viewables(
                                following: true
                            )
                        ),
                        User(
                            id: "RamyaKembal",
                            name: "Ramya kembal",
                            email: "ramya@gmail.com",
                            username: "RamyaKembal",
                            image: "https://pbs.twimg.com/profile_images/1190200299727851526/A26tGnda_400x400.jpg",
                            description: """
                            I'm simple and soft.
                            """,
                            creationDate: .now(),
                            lastUpdatedDate: .now(),
                            socialDetails: User.SocialDetails(
                                followersCount: 0,
                                followeesCount: 0
                            ),
                            activityDetails: User.ActivityDetails(
                                tweetsCount: 0
                            ),
                            viewables: User.Viewables(
                                following: true
                            )
                        ),
                        User(
                            id: "GabbbarSingh",
                            name: "Gabbar",
                            email: "gabbar@gmail.com",
                            username: "GabbbarSingh",
                            image: "https://pbs.twimg.com/profile_images/1271082702326784003/1kIF_loZ_400x400.jpg",
                            description: """
                            Co-Founder @JoinZorro | Founder @GingerMonkeyIN
                            """,
                            creationDate: .now(),
                            lastUpdatedDate: .now(),
                            socialDetails: User.SocialDetails(
                                followersCount: 0,
                                followeesCount: 0
                            ),
                            activityDetails: User.ActivityDetails(
                                tweetsCount: 0
                            ),
                            viewables: User.Viewables(
                                following: true
                            )
                        )
                    ]
                    
                    
                    let filteredUsers = users.filter { user in
                        user.username.lowercased().hasPrefix(keyword.lowercased())
                    }
                    
                    let result = Paginated<User>(
                        page: filteredUsers,
                        nextToken: nil
                    )
                    
                    continuation.resume(returning: result)
                }
        }
        
        return .success(paginated)
    }
    
    private func captureKeyword(_ keyword: String) async {
        if await TXLocalStorageAssistant.shallow.exists(key: SearchDataStore.keywordsStorageKey) {
            let previousKeywords: TXLocalStorageElement<[String]> = try! await TXLocalStorageAssistant.shallow.retrieve(
                key: SearchDataStore.keywordsStorageKey
            )
            
            do {
                // We're storing only the latest 6
                
                var latestKeywords: [String]
                
                if let indexOfKeyword = previousKeywords.value.firstIndex(of: keyword) {
                    latestKeywords = previousKeywords.value
                    
                    latestKeywords.remove(at: indexOfKeyword)
                } else {
                    latestKeywords = previousKeywords.value.count > 5
                    ? Array(previousKeywords.value[..<5])
                    : previousKeywords.value
                }
                
                latestKeywords.insert(keyword, at: 0)
                
                let _ = try await TXLocalStorageAssistant.shallow.update(
                    key: SearchDataStore.keywordsStorageKey,
                    value: latestKeywords
                )
            } catch {
                // Do nothing
            }
        } else {
            do {
                let latestKeywords = [keyword]
                
                let _ = try await TXLocalStorageAssistant.shallow.store(
                    key: SearchDataStore.keywordsStorageKey,
                    value: latestKeywords
                )
            } catch {
                // Do nothing
            }
        }
    }
    
    func previousSearchKeywords() async -> Result<[String], PreviousSearchKeywordsFailure> {
        do {
            let previousKeywords: TXLocalStorageElement<[String]> = try await TXLocalStorageAssistant.shallow.retrieve(
                key: SearchDataStore.keywordsStorageKey
            )
            
            let latestKeywords = previousKeywords.value
            
            return .success(latestKeywords)
        } catch {
            // do nothing
            return .failure(.unknown)
        }
    }
}

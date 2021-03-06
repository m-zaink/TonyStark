//
//  SearchDataStore.swift
//  TonyStark
//
//  Created by Mohammed Sadiq on 29/04/22.
//

import Foundation

class SearchDataStore: DataStore {
    static let shared = SearchDataStore()
    
    private static let keywordsStorageKey = "keywordsStorageKey"
    
    private static let searchURL = "\(SearchDataStore.baseUrl)/search"
    
    private override init() { }
    
    override func bootUp() async {
        // Do nothing
    }
    
    override func bootDown() async {
        // Do nothing
    }
    
    func search(
        withKeyword keyword: String,
        after nextToken: String? = nil
    ) async -> Result<Paginated<User>, SearchFailure> {
        await captureKeyword(keyword)
        
        if let session = CurrentUserDataStore.shared.session {
            do {
                var query = [
                    "keyword": keyword,
                ]
                
                if let nextToken = nextToken {
                    query["nextToken"] = nextToken
                }
                
                let searchResult = try await TXNetworkAssistant.shared.get(
                    url: Self.searchURL,
                    query: query,
                    headers: secureHeaders(
                        withAccessToken: session.accessToken
                    )
                )
                
                if searchResult.statusCode == 200 {
                    let paginatedSearch = try TXJsonAssistant.decode(
                        SuccessData<Paginated<User>>.self,
                        from: searchResult.data
                    ).data
                    
                    return .success(paginatedSearch)
                } else {
                    return .failure(.unknown)
                }
            } catch {
                return .failure(.unknown)
            }
        } else {
            return .failure(.unknown)
        }
    }
    
    private func captureKeyword(_ keyword: String) async {
        let keywordExists = await TXLocalStorageAssistant.shallow.exists(key: SearchDataStore.keywordsStorageKey)
        
        do {
            if keywordExists {
                let previousKeywords: TXLocalStorageElement<[String]>
                
                previousKeywords = try await TXLocalStorageAssistant.shallow.retrieve(
                    key: SearchDataStore.keywordsStorageKey
                )
                
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
            } else {
                let latestKeywords = [keyword]
                
                let _ = try await TXLocalStorageAssistant.shallow.store(
                    key: SearchDataStore.keywordsStorageKey,
                    value: latestKeywords
                )
            }
        } catch {
            // Do nothing
        }
    }
    
    func previouslySearchKeywords() async -> Result<[String], PreviousSearchKeywordsFailure> {
        do {
            let previousKeywords: TXLocalStorageElement<[String]> = try await TXLocalStorageAssistant.shallow.retrieve(
                key: SearchDataStore.keywordsStorageKey
            )
            
            let latestKeywords = previousKeywords.value
            
            return .success(latestKeywords)
        } catch {
            return .failure(.unknown)
        }
    }
}

//
//  FollowersViewController.swift
//  TonyStark
//
//  Created by Mohammed Sadiq on 29/04/22.
//

import UIKit

class FollowersViewController: TXViewController {
    // Declare
    enum FollowersTableViewSection: Int, CaseIterable {
        case followers
    }
    
    private(set) var user: User = .default
    
    private var state: State<Paginated<Follower>, FollowersFailure> = .processing
    
    private let tableView: TXTableView = {
        let tableView = TXTableView()
        
        tableView.enableAutolayout()
        
        return tableView
    }()
    
    // Configure
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        
        configureNavigationBar()
        configureTableView()
        configureRefreshControl()
        
        populateTableView()
    }
    
    private func addSubviews() {
        view.addSubview(tableView)
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Followers"
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.appendSpacerOnHeader()
        
        tableView.register(
            PartialUserTableViewCell.self,
            forCellReuseIdentifier: PartialUserTableViewCell.reuseIdentifier
        )
        
        tableView.pin(
            to: view,
            byBeingSafeAreaAware: true
        )
    }
    
    private func configureRefreshControl() {
        let refreshControl = TXRefreshControl()
        refreshControl.delegate = self
        
        tableView.refreshControl = refreshControl
    }
    
    // Populate
    func populate(withUser user: User) {
        self.user = user
    }
    
    // Interact
}

// MARK: TXTableViewDataSource
extension FollowersViewController: TXTableViewDataSource {
    private func populateTableView() {
        Task {
            tableView.beginPaginating()
            
            let followersResult = await SocialsDataStore.shared.followers(ofUserWithId: user.id)
            
            tableView.endPaginating()
            
            followersResult.map { paginatedFollowers in
                state = .success(paginatedFollowers)
            } onFailure: { cause in
                state = .failure(cause)
            }

            tableView.reloadData()
        }
    }
    
    private func refreshTableView() {
        Task {
            tableView.beginRefreshing()
            
            let followersResult = await SocialsDataStore.shared.followers(ofUserWithId: user.id)
            
            tableView.endRefreshing()
            
            followersResult.map { paginatedFollowers in
                state = .success(paginatedFollowers)
            } onFailure: { cause in
                state = .failure(cause)
            }

            tableView.reloadData()
        }
    }
    
    private func extendTableView() {
        state.mapOnlyOnSuccess { previousPaginatedFollowers in
            guard let nextToken = previousPaginatedFollowers.nextToken else {
                return
            }
            
            Task {
                tableView.beginPaginating()
                
                let followersResult = await SocialsDataStore.shared.followers(
                    ofUserWithId: user.id,
                    after: nextToken
                )
                
                tableView.endPaginating()
                
                followersResult.mapOnlyOnSuccess { latestPaginatedFollowers in
                    let updatedPaginatedFollowers = Paginated<Follower>(
                        page: previousPaginatedFollowers.page + latestPaginatedFollowers.page,
                        nextToken: latestPaginatedFollowers.nextToken
                    )
                    
                    tableView.appendSepartorToLastMostVisibleCell()
                    
                    state = .success(updatedPaginatedFollowers)
                    tableView.reloadData()
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        FollowersTableViewSection.allCases.count
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        state.mapOnSuccess { paginatedFollowers in
            paginatedFollowers.page.count
        } orElse: {
            0
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        state.mapOnSuccess { paginatedFollowers in
            let follower = paginatedFollowers.page[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PartialUserTableViewCell.reuseIdentifier,
                for: indexPath
            ) as! PartialUserTableViewCell
            
            cell.interactionsHandler = self
            cell.configure(withUser: follower.user)
            
            return cell
        } orElse: {
            TXTableViewCell()
        }
    }
}

// MARK: TXTableViewDelegate
extension FollowersViewController: TXTableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row == tableView.numberOfRows(inSection: FollowersTableViewSection.followers.rawValue) - 1 {
            tableView.removeSeparatorOnCell(cell)
            
            extendTableView()
        } else {
            tableView.appendSeparatorOnCell(cell)
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        TXTableView.automaticDimension
    }
}

// MARK: TXRefreshControlDelegate
extension FollowersViewController: TXRefreshControlDelegate {
    func refreshControlDidChange(_ control: TXRefreshControl) {
        if control.isRefreshing {
            refreshTableView()
        }
    }
}

// MARK: PartialUserTableViewCellInteractionsHandler
extension FollowersViewController: PartialUserTableViewCellInteractionsHandler {
    func partialUserCellDidPressProfileImage(_ cell: PartialUserTableViewCell) {
        state.mapOnlyOnSuccess { paginatedFollowers in
            guard let follower = paginatedFollowers.page.first(where: { $0.user.id == cell.user.id }) else {
                return
            }
            
            navigationController?.openUserViewController(withUser: follower.user)
        }
    }
}

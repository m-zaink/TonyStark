//
//  ProfileViewController.swift
//  TonyStark
//
//  Created by Mohammed Sadiq on 16/03/22.
//

import UIKit

enum ProfileViewControllerSection: Int, CaseIterable {
    case profile = 0
    case tweets = 1
}

class CurrentUserViewController: TXTableViewController {
    private var state: Result<Paginated<Tweet>, TweetsProvider.TweetsFailure> = .success(.empty())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureTableView()
        
        populate()
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = TXBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal"),
            style: .plain,
            target: self,
            action: #selector(onActionPressed(_:))
        )
    }
    
    private func configureTableView() {
        tableView.register(
            CurrentUserTableViewCell.self,
            forCellReuseIdentifier: CurrentUserTableViewCell.reuseIdentifier
        )
        
        tableView.register(
            TweetTableViewCell.self,
            forCellReuseIdentifier: TweetTableViewCell.reuseIdentifier
        )
    }
    
    @objc private func onActionPressed(
        _ sender: UIBarButtonItem
    ) {
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let appInformationAction = UIAlertAction(
            title: "App Information",
            style: .default
        ) { action in
            // TODO:
        }
        
        let developerInformationAction = UIAlertAction(
            title: "Developer Information",
            style: .default
        ) { action in
            // TODO:
        }
        
        let bookmarksAction = UIAlertAction(
            title: "Bookmarks",
            style: .default
        ) { action in
            // TODO:
        }
    
        let logOutAction = UIAlertAction(
            title: "Log Out?",
            style: .destructive
        ) { action in
            // TODO:
        }
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel
        ) { action in
            alert.dismiss(animated: true)
        }
        
        alert.addAction(appInformationAction)
        alert.addAction(developerInformationAction)
        alert.addAction(bookmarksAction)
        alert.addAction(logOutAction)
        alert.addAction(cancelAction)
        
        present(
            alert,
            animated: true
        )
    }
}

// MARK: UITableViewDataSource
extension CurrentUserViewController {
    private func populate() {
        Task {
            [weak self] in
            let result = await TweetsProvider.shared.tweets(of: "mzaink")
            
            self?.state = result
            self?.tableView.reloadSections(
                [ProfileViewControllerSection.tweets.rawValue],
                with: .automatic
            )
        }
    }
    
    override func numberOfSections(
        in tableView: UITableView
    ) -> Int {
        return ProfileViewControllerSection.allCases.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        switch section {
        case ProfileViewControllerSection.profile.rawValue:
            return 1
        case ProfileViewControllerSection.tweets.rawValue:
            switch state {
            case .success(let paginated):
                return paginated.page.count
            case .failure(_):
                return 0
            }
        default:
            fatalError()
        }
        
    }
    
    override func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: UITableViewDelegate
extension CurrentUserViewController {
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        switch indexPath.section {
        case ProfileViewControllerSection.profile.rawValue:
            let cell = tableView.dequeueReusableCellWithIndexPath(
                withIdentifier: CurrentUserTableViewCell.reuseIdentifier,
                for: indexPath
            ) as! CurrentUserTableViewCell
            
            cell.interactionsHandler = self
            cell.configure(withUser: UserProvider.current.user)
            
            return cell
            
        case ProfileViewControllerSection.tweets.rawValue:
            switch state {
            case .success(let paginated):
                let cell = tableView.dequeueReusableCellWithIndexPath(
                    withIdentifier: TweetTableViewCell.reuseIdentifier,
                    for: indexPath
                ) as! TweetTableViewCell
                
                cell.interactionsHandler = self
                cell.configure(withTweet: paginated.page[indexPath.row])
                
                return cell
            case .failure(_):
                return UITableViewCell()
            }
        default:
            fatalError()
        }
    }
}

// MARK: UIScrollViewDelegate
extension CurrentUserViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentYOffset = scrollView.contentOffset.y
        
        if currentYOffset < 140 {
            navigationItem.title = nil
        }
        
        if currentYOffset > 140 && navigationItem.title == nil {
            navigationItem.title = UserProvider.current.user.name
        }
    }
}

// MARK: CurrentUserDetailsTableViewCellDelegate
extension CurrentUserViewController: CurrentUserTableViewCellInteractionsHandler {
    func didPressEdit(_ cell: CurrentUserTableViewCell) {
        let navigationViewController = TXNavigationController(
            rootViewController: EditProfileViewController(
                style: .insetGrouped
            )
        )
        
        navigationViewController.modalPresentationStyle = .fullScreen
        
        present(
            navigationViewController,
            animated: true
        )
    }
    
    func didPressFollowers(_ cell: CurrentUserTableViewCell) {
        let followersViewController = FollowersViewController()
        
        navigationController?.pushViewController(
            followersViewController,
            animated: true
        )
    }
    
    func didPressFollowings(_ cell: CurrentUserTableViewCell) {
        let followingsViewController = FollowingsViewController()
        
        navigationController?.pushViewController(
            followingsViewController,
            animated: true
        )
    }
}

extension CurrentUserViewController: TweetTableViewCellInteractionsHandler {
    func didPressLike(_ cell: TweetTableViewCell) {
        print(#function)
    }
    
    func didPressComment(_ cell: TweetTableViewCell) {
        let commentsViewController = CommentsViewController()
        
        let navigationController = TXNavigationController(
            rootViewController: commentsViewController
        )
        
        present(
            navigationController,
            animated: true
        )
    }
    
    func didPressProfileImage(_ cell: TweetTableViewCell) {
        print(#function)
    }
    
    func didPressBookmarksOption(_ cell: TweetTableViewCell) {
        print(#function)
    }
    
    func didPressFollowOption(_ cell: TweetTableViewCell) {
        print(#function)
    }
    
    func didPressOption(_ cell: TweetTableViewCell) {
        switch state {
        case .success(let paginated):
            let alert = TweetOptionsAlertViewController.regular()
            
            alert.configure(withTweet: paginated.page[cell.indexPath.row])
            
            present(
                alert,
                animated: true
            )
        default:
            break
        }
    }
}
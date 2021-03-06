//
//  ProfileViewController.swift
//  TonyStark
//
//  Created by Mohammed Sadiq on 16/03/22.
//

import UIKit

class SelfViewController: TXFloatingActionViewController {
    // Declare
    enum SelfTableViewSection: Int, CaseIterable {
        case user
        case tweets
    }
    
    private var state: State<Paginated<Tweet>, TweetsFailure> = .processing
    
    private var tableView: TXTableView = {
        let tableView = TXTableView()
        
        tableView.enableAutolayout()
        
        return tableView
    }()
    
    // Configure
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureEventListener()
        
        addSubviews()
        
        configureNavigationBar()
        configureTableView()
        configureRefreshControl()
        
        populateTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
    }
    
    private func addSubviews() {
        containerView.addSubview(tableView)
    }
    
    private func configureNavigationBar() {
        navigationItem.backButtonTitle = ""
        navigationItem.rightBarButtonItem = TXBarButtonItem(
            image: UIImage(
                systemName: "line.3.horizontal"
            ),
            style: .plain,
            target: self,
            action: #selector(onActionPressed(_:))
        )
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.appendSpacerOnHeader()
        
        tableView.register(
            CurrentUserTableViewCell.self,
            forCellReuseIdentifier: CurrentUserTableViewCell.reuseIdentifier
        )
        tableView.register(
            EmptySelfTweetsTableViewCell.self,
            forCellReuseIdentifier: EmptySelfTweetsTableViewCell.reuseIdentifier
        )
        tableView.register(
            PartialTweetTableViewCell.self,
            forCellReuseIdentifier: PartialTweetTableViewCell.reuseIdentifier
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
    
    // Interact
    @objc private func onActionPressed(
        _ sender: UIBarButtonItem
    ) {
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let bookmarksAction = UIAlertAction(
            title: "Bookmarks",
            style: .default
        ) { [weak self] action in
            guard let strongSelf = self else {
                return
            }
            
            let bookmarksViewController = BookmarksViewController()
            
            strongSelf.navigationController?.pushViewController(
                bookmarksViewController,
                animated: true
            )
        }
        
        let logOutAction = UIAlertAction(
            title: "Log Out",
            style: .destructive
        ) {
            [weak self] action in
            guard let strongSelf = self else {
                return
            }
            
            Task {
                strongSelf.showActivityIndicator()
                
                let result = await CurrentUserDataStore.shared.logOut()
                
                strongSelf.hideActivityIndicator()
                
                result.mapOnlyOnFailure { failure in
                    strongSelf.showUnknownFailureSnackBar()
                }
            }
        }
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel
        ) { action in
            alert.dismiss(animated: true)
        }
        
        alert.addAction(bookmarksAction)
        alert.addAction(logOutAction)
        alert.addAction(cancelAction)
        
        present(
            alert,
            animated: true
        )
    }
    
    override func onFloatingActionPressed() {
        navigationController?.openComposeViewController()
    }
    
}

// MARK: TXEventListener
extension SelfViewController {
    private func configureEventListener() {
        TXEventBroker.shared.listen {
            [weak self] event in
            guard let strongSelf = self else {
                return
            }
            
            if let event = event as? HomeTabSwitchEvent {
                strongSelf.onTabSwitched(to: event.tab)
            }
            
            if let event = event as? TweetCreatedEvent {
                strongSelf.onTweetCreated(
                    tweet: event.tweet
                )
            }
            
            if let event = event as? TweetDeletedEvent {
                strongSelf.onTweetDeleted(
                    withId: event.id
                )
            }
            
            if let event = event as? LikeCreatedEvent {
                strongSelf.onTweetLiked(
                    withId: event.tweetId
                )
            }
            
            if let event = event as? LikeDeletedEvent {
                strongSelf.onTweetUnliked(
                    withId: event.tweetId
                )
            }
            
            if event is RefreshedCurrentUserEvent {
                strongSelf.onCurrentUserRefreshed()
            }
            
            if let event = event as? BookmarkCreatedEvent {
                strongSelf.onBookmarkCreated(
                    ofTweetWithId: event.tweetId
                )
            }
            
            if let event = event as? BookmarkDeletedEvent {
                strongSelf.onBookmarkDeleted(
                    ofTweetWithId: event.tweetId
                )
            }
        }
    }
    
    private func onTabSwitched(
        to tab: HomeViewController.TabItem
    ) {
        if tab == .user {
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    private func onTweetCreated(
        tweet: Tweet
    ) {
        state.mapOnlyOnSuccess { previousPaginatedTweets in
            let updatedPaginatedTweets = Paginated<Tweet>(
                page: [tweet] + previousPaginatedTweets.page,
                nextToken: previousPaginatedTweets.nextToken
            )
            
            state = .success(updatedPaginatedTweets)
            
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 0.1
            ) {
                [weak self] in
                guard let strongSelf = self, strongSelf.tableView.window != nil else {
                    return
                }
                
                strongSelf.tableView.reloadData()
                strongSelf.tableView.appendSepartorToLastMostVisibleCell()
            }
        }
    }
    
    private func onTweetDeleted(
        withId id: String
    ) {
        state.mapOnlyOnSuccess { previousPaginatedTweets in
            let updatedPaginatedTweets = Paginated<Tweet>(
                page: previousPaginatedTweets.page.filter { $0.id != id },
                nextToken: previousPaginatedTweets.nextToken
            )
            
            state = .success(updatedPaginatedTweets)
            
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 0.1
            ) {
                [weak self] in
                guard let strongSelf = self, strongSelf.tableView.window != nil else {
                    return
                }
                
                strongSelf.tableView.reloadData()
            }
        }
    }
    
    private func onTweetLiked(withId id: String) {
        state.mapOnlyOnSuccess { previousPaginatedTweets in
            let updatedPaginatedTweets = Paginated<Tweet>(
                page: previousPaginatedTweets.page.map { tweet in
                    if tweet.id == id && !tweet.viewables.liked {
                        return tweet.copyWith(
                            interactionDetails: tweet.interactionDetails.copyWith(
                                likesCount: tweet.interactionDetails.likesCount + 1
                            ),
                            viewables: tweet.viewables.copyWith(
                                liked: true
                            )
                        )
                    } else {
                        return tweet
                    }
                },
                nextToken: previousPaginatedTweets.nextToken
            )
            
            state = .success(updatedPaginatedTweets)
            
            DispatchQueue.main.asyncAfter (
                deadline: .now() + 0.1
            ) {
                [weak self] in
                guard let strongSelf = self, strongSelf.tableView.window != nil else {
                    return
                }
                
                strongSelf.tableView.reloadData()
            }
        }
    }
    
    private func onTweetUnliked(withId id: String) {
        state.mapOnlyOnSuccess { previousPaginatedTweets in
            let updatedPaginatedTweets = Paginated<Tweet>(
                page: previousPaginatedTweets.page.map { tweet in
                    if tweet.id == id && tweet.viewables.liked {
                        return tweet.copyWith(
                            interactionDetails: tweet.interactionDetails.copyWith(
                                likesCount: tweet.interactionDetails.likesCount - 1
                            ),
                            viewables: tweet.viewables.copyWith(
                                liked: false
                            )
                        )
                    } else {
                        return tweet
                    }
                },
                nextToken: previousPaginatedTweets.nextToken
            )
            
            state = .success(updatedPaginatedTweets)
            
            DispatchQueue.main.asyncAfter (
                deadline: .now() + 0.1
            ) {
                [weak self] in
                guard let strongSelf = self, strongSelf.tableView.window != nil else {
                    return
                }
                
                strongSelf.tableView.reloadData()
            }
        }
    }
    
    private func onCurrentUserRefreshed() {
        if let currentUser = CurrentUserDataStore.shared.user {
            state.mapOnlyOnSuccess { previousPaginatedTweets in
                var indices: [Int] = []
                
                previousPaginatedTweets.page.enumerated().forEach { index, tweet in
                    if tweet.viewables.author.id == currentUser.id {
                        indices.append(
                            index
                        )
                    }
                }
                
                let updatedPaginatedTweets = Paginated<Tweet>(
                    page: previousPaginatedTweets.page.map { tweet in
                        if tweet.viewables.author.id == currentUser.id {
                            let viewables = tweet.viewables
                            let updatedViewables = viewables.copyWith(
                                author: currentUser
                            )
                            
                            return tweet.copyWith(
                                viewables: updatedViewables
                            )
                        } else {
                            return tweet
                        }
                    },
                    nextToken: previousPaginatedTweets.nextToken
                )
                
                state = .success(updatedPaginatedTweets)
                
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 0.1
                ) {
                    [weak self] in
                    guard let strongSelf = self, strongSelf.tableView.window != nil else {
                        return
                    }
                    
                    strongSelf.tableView.reloadData()
                }
            }
        }
    }
    
    private func onBookmarkCreated(
        ofTweetWithId tweetId: String
    ) {
        state.mapOnlyOnSuccess { previousPaginatedTweets in
            let updatedPaginatedTweets = Paginated<Tweet>(
                page: previousPaginatedTweets.page.map { tweet in
                    if tweet.id == tweetId && !tweet.viewables.bookmarked {
                        let viewables = tweet.viewables
                        let updatedViewables = viewables.copyWith(
                            bookmarked: true
                        )
                        
                        return tweet.copyWith(
                            viewables: updatedViewables
                        )
                    } else {
                        return tweet
                    }
                },
                nextToken: previousPaginatedTweets.nextToken
            )
            
            state = .success(updatedPaginatedTweets)
            
            DispatchQueue.main.asyncAfter (
                deadline: .now() + 0.1
            ) {
                [weak self] in
                guard let strongSelf = self, strongSelf.tableView.window != nil else {
                    return
                }
                
                strongSelf.tableView.reloadData()
            }
        }
    }
    
    private func onBookmarkDeleted(
        ofTweetWithId tweetId: String
    ) {
        state.mapOnlyOnSuccess { previousPaginatedTweets in
            let updatedPaginatedTweets = Paginated<Tweet>(
                page: previousPaginatedTweets.page.map { tweet in
                    if tweet.id == tweetId && tweet.viewables.bookmarked {
                        let viewables = tweet.viewables
                        let updatedViewables = viewables.copyWith(
                            bookmarked: false
                        )
                        
                        return tweet.copyWith(
                            viewables: updatedViewables
                        )
                    } else {
                        return tweet
                    }
                },
                nextToken: previousPaginatedTweets.nextToken
            )
            
            state = .success(updatedPaginatedTweets)
            
            DispatchQueue.main.asyncAfter (
                deadline: .now() + 0.1
            ) {
                [weak self] in
                guard let strongSelf = self, strongSelf.tableView.window != nil else {
                    return
                }
                
                strongSelf.tableView.reloadData()
            }
        }
    }
}

// MARK: TXTableViewDataSource
extension SelfViewController: TXTableViewDataSource {
    private func populateTableView() {
        Task {
            tableView.beginPaginating()
            
            let tweetsResult = await TweetsDataStore.shared.tweets(
                ofUserWithId: CurrentUserDataStore.shared.user!.id
            )
            
            tableView.endPaginating()
            
            tweetsResult.map { paginatedTweets in
                state = .success(paginatedTweets)
                tableView.reloadSections(
                    IndexSet(
                        integer: SelfTableViewSection.tweets.rawValue
                    ),
                    with: .automatic
                )
                tableView.appendSpacerOnFooter()
            } onFailure: { cause in
                state = .failure(cause)
            }
        }
    }
    
    private func refreshTableView() {
        Task {
            tableView.beginRefreshing()
            
            await refreshUserSection()
            await refreshTweetsSection()
            
            tableView.endRefreshing()
        }
    }
    
    private func extendTableView() {
        state.mapOnlyOnSuccess { previousPaginatedTweets in
            if let nextToken = previousPaginatedTweets.nextToken {
                Task {
                    tableView.beginPaginating()
                    
                    let tweetsResult = await TweetsDataStore.shared.tweets(
                        ofUserWithId: CurrentUserDataStore.shared.user!.id,
                        after: nextToken
                    )
                    
                    tableView.endPaginating()
                    
                    tweetsResult.map { latestPaginatedTweets in
                        let updatedPaginatedTweets = Paginated<Tweet>(
                            page: previousPaginatedTweets.page + latestPaginatedTweets.page,
                            nextToken: latestPaginatedTweets.nextToken
                        )
                        
                        state = .success(updatedPaginatedTweets)
                        
                        tableView.reloadData()
                        
                        tableView.appendSepartorToLastMostVisibleCell()
                    } onFailure: { cause in
                        showUnknownFailureSnackBar()
                    }
                }
            }
        }
    }
    
    private func refreshUserSection() async {
        let userRefreshResult = await CurrentUserDataStore.shared.refreshUser()
        
        userRefreshResult.mapOnSuccess {
            DispatchQueue.main.async {
                [weak self] in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.tableView.reloadSections(
                    IndexSet(
                        integer: SelfTableViewSection.user.rawValue
                    ),
                    with: .none
                )
            }
        } orElse: {
            showUnknownFailureSnackBar()
        }
    }
    
    private func refreshTweetsSection() async {
        let tweetsResult = await TweetsDataStore.shared.tweets(
            ofUserWithId: CurrentUserDataStore.shared.user!.id
        )
        
        tweetsResult.mapOnSuccess {
            paginatedTweets in
            
            DispatchQueue.main.async {
                [weak self] in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.state = .success(paginatedTweets)
                strongSelf.tableView.reloadSections(
                    IndexSet(
                        integer: SelfTableViewSection.tweets.rawValue
                    ),
                    with: .none
                )
                strongSelf.tableView.appendSpacerOnFooter()
            }
        } orElse: {
            showUnknownFailureSnackBar()
        }
    }
    
    func numberOfSections(
        in tableView: UITableView
    ) -> Int {
        SelfTableViewSection.allCases.count
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        switch section {
        case SelfTableViewSection.user.rawValue:
            return 1
        case SelfTableViewSection.tweets.rawValue:
            return state.mapOnSuccess { paginatedTweets in
                if paginatedTweets.page.isEmpty {
                    return 1
                } else {
                    return paginatedTweets.page.count
                }
            } orElse: {
                0
            }
        default:
            fatalError()
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        switch indexPath.section {
        case SelfTableViewSection.user.rawValue:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CurrentUserTableViewCell.reuseIdentifier,
                for: indexPath
            ) as! CurrentUserTableViewCell
            
            cell.interactionsHandler = self
            cell.configure(withUser: CurrentUserDataStore.shared.user!)
            
            return cell
        case SelfTableViewSection.tweets.rawValue:
            return state.mapOnSuccess { paginatedTweets in
                if paginatedTweets.page.isEmpty {
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: EmptySelfTweetsTableViewCell.reuseIdentifier,
                        for: indexPath
                    ) as! EmptySelfTweetsTableViewCell
                    
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: PartialTweetTableViewCell.reuseIdentifier,
                        for: indexPath
                    ) as! PartialTweetTableViewCell
                    
                    cell.interactionsHandler = self
                    cell.configure(withTweet: paginatedTweets.page[indexPath.row])
                    
                    return cell
                }
            } orElse: {
                TXTableViewCell()
            }
        default:
            fatalError()
        }
    }
}

// MARK: TXTableViewDelegate
extension SelfViewController: TXTableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        switch indexPath.section {
        case SelfTableViewSection.user.rawValue:
            tableView.appendSeparatorOnCell(
                cell,
                withInset: .leading(0)
            )
        case SelfTableViewSection.tweets.rawValue:
            state.mapOnlyOnSuccess { paginatedTweets in
                if paginatedTweets.page.isEmpty {
                    return
                }
                
                if indexPath.row == paginatedTweets.page.count - 1 {
                    extendTableView()
                }
            }
        default:
            fatalError()
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(
            at: indexPath,
            animated: true
        )
        
        if indexPath.section == SelfTableViewSection.tweets.rawValue {
            state.mapOnlyOnSuccess { paginatedTweets in
                let tweet = paginatedTweets.page[indexPath.row]
                
                let tweetViewController = TweetViewController()
                tweetViewController.populate(withTweet: tweet)
                
                navigationController?.pushViewController(
                    tweetViewController,
                    animated: true
                )
            }
        }
    }
}

// MARK: TXScrollViewDelegate
extension SelfViewController: TXScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentYOffset = scrollView.contentOffset.y
        
        if currentYOffset < 120 {
            navigationItem.title = nil
        }
        
        if currentYOffset > 120 && navigationItem.title == nil {
            navigationItem.title = CurrentUserDataStore.shared.user!.name
        }
    }
}

// MARK: TXRefreshControlDelegate
extension SelfViewController: TXRefreshControlDelegate {
    func refreshControlDidChange(_ control: TXRefreshControl) {
        if control.isRefreshing {
            refreshTableView()
        }
    }
}

// MARK: CurrentUserDetailsTableViewCellDelegate
extension SelfViewController: CurrentUserTableViewCellInteractionsHandler {
    func currentUserCellDidPressEdit(_ cell: CurrentUserTableViewCell) {
        let editUserDetailsViewController = EditSelfViewController()
        
        editUserDetailsViewController.populate(
            withUser: CurrentUserDataStore.shared.user!
        )
        
        let navigationViewController = TXNavigationController(
            rootViewController: editUserDetailsViewController
        )
        
        navigationViewController.modalPresentationStyle = .fullScreen
        
        present(
            navigationViewController,
            animated: true
        )
    }
    
    func currentUserCellDidPressFollowers(_ cell: CurrentUserTableViewCell) {
        if CurrentUserDataStore.shared.user!.socialDetails.followersCount > 0 {
            let followersViewController = FollowersViewController()
            
            followersViewController.populate(
                withUser: CurrentUserDataStore.shared.user!
            )
            
            navigationController?.pushViewController(
                followersViewController, animated: true
            )
        }
    }
    
    func currentUserCellDidPressFollowings(_ cell: CurrentUserTableViewCell) {
        if CurrentUserDataStore.shared.user!.socialDetails.followeesCount > 0 {
            let followingsViewController = FolloweesViewController()
            
            followingsViewController.populate(
                withUser: CurrentUserDataStore.shared.user!
            )
            
            navigationController?.pushViewController(
                followingsViewController, animated: true
            )
        }
    }
}

// MARK: PartialTweetTableViewCellInteractionsHandler
extension SelfViewController: PartialTweetTableViewCellInteractionsHandler {
    func partialTweetCellDidPressLike(_ cell: PartialTweetTableViewCell) {
        state.mapOnlyOnSuccess { paginatedFeed in
            if cell.tweet.viewables.liked {
                onTweetUnliked(
                    withId: cell.tweet.id
                )
            } else {
                onTweetLiked(
                    withId: cell.tweet.id
                )
            }
            
            Task {
                if cell.tweet.viewables.liked {
                    let likeCreationResult = await LikesDataStore.shared.deleteLike(
                        onTweetWithId: cell.tweet.id
                    )
                    
                    likeCreationResult.mapOnlyOnFailure { failure in
                        showUnknownFailureSnackBar()
                        
                        onTweetLiked(
                            withId: cell.tweet.id
                        )
                    }
                } else {
                    let likeDeletionResult = await LikesDataStore.shared.createLike(
                        onTweetWithId: cell.tweet.id
                    )
                    
                    likeDeletionResult.mapOnlyOnFailure { failure in
                        showUnknownFailureSnackBar()
                        
                        onTweetUnliked(
                            withId: cell.tweet.id
                        )
                    }
                }
            }
        }
    }
    
    func partialTweetCellDidPressComment(_ cell: PartialTweetTableViewCell) {
        state.mapOnlyOnSuccess { paginatedTweets in
            guard let tweet = paginatedTweets.page.first(where: { $0.id == cell.tweet.id }) else {
                return
            }
            
            navigationController?.openTweetViewController(
                withTweet: tweet,
                andOptions: .init(
                    autoFocus: true
                )
            )
        }
    }
    
    func partialTweetCellDidPressProfileImage(_ cell: PartialTweetTableViewCell) {
        print(#function)
    }
    
    func partialTweetCellDidPressBookmarkOption(_ cell: PartialTweetTableViewCell) {
        Task {
            if cell.tweet.viewables.bookmarked {
                let bookmarkDeletionResult = await BookmarksDataStore.shared.deleteBookmark(
                    onTweetWithId: cell.tweet.id
                )
                
                bookmarkDeletionResult.map {
                    showBookmarkDeletedSnackBar()
                } onFailure: { failure in
                    showUnknownFailureSnackBar()
                }
            } else {
                let bookmarkCreationResult = await BookmarksDataStore.shared.createBookmark(
                    onTweetWithId: cell.tweet.id
                )
                
                bookmarkCreationResult.map {
                    showBookmarkCreatedSnackBar()
                } onFailure: { failure in
                    showUnknownFailureSnackBar()
                }
            }
        }
    }
    
    func partialTweetCellDidPressFollowOption(
        _ cell: PartialTweetTableViewCell
    ) {
        print(#function)
    }
    
    func partialTweetCellDidPressDeleteOption(_ cell: PartialTweetTableViewCell) {
        state.mapOnlyOnSuccess { paginatedTweets in
            guard let tweet = paginatedTweets.page.first(where: { $0.id == cell.tweet.id }) else {
                return
            }
            
            Task {
                cell.prepareForDelete()
                
                let tweetDeletionResult = await TweetsDataStore.shared.deleteTweet(
                    withId: tweet.id
                )
                
                tweetDeletionResult.mapOnlyOnFailure { failure in
                    cell.revertAllPreparationsMadeForDelete()
                    showUnknownFailureSnackBar()
                }
            }
            return
        }
    }
    
    func partialTweetCellDidPressOptions(_ cell: PartialTweetTableViewCell) {
        state.mapOnlyOnSuccess { paginatedTweets in
            guard let tweet = paginatedTweets.page.first(where: { $0.id == cell.tweet.id }) else {
                return
            }
            
            let alert = TweetOptionsAlertController.regular()
            
            alert.interactionsHandler = self
            alert.configure(
                withTweet: tweet
            )
            
            present(
                alert,
                animated: true
            )
        }
    }
}

// MARK: TweetOptionsAlertViewControllerInteractionsHandler
extension SelfViewController: TweetOptionsAlertControllerInteractionsHandler {
    func tweetOptionsAlertControllerDidPressBookmark(_ controller: TweetOptionsAlertController) {
        print(#function)
    }
    
    func tweetOptionsAlertControllerDidPressFollow(_ controller: TweetOptionsAlertController) {
        print(#function)
    }
    
    func tweetOptionsAlertControllerDidPressDelete(_ controller: TweetOptionsAlertController) {
        print(#function)
    }
}

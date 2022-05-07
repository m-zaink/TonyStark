//
//  FeedViewController.swift
//  TonyStark
//
//  Created by Mohammed Sadiq on 16/03/22.
//

import UIKit

class ComposeTweetEvent: TXEvent {
    
}

class FeedViewController: TXViewController {
    // Declare
    private var state: Result<Paginated<Tweet>, FeedFailure> = .success(.default())
    
    private let tableView: TXTableView = {
        let tableView = TXTableView()
        
        tableView.enableAutolayout()
        
        return tableView
    }()
    
    private let floatingButton: FloatingButton = {
        let floatingButton = FloatingButton()
        
        floatingButton.enableAutolayout()
        floatingButton.setImage(
            UIImage(systemName: "plus"),
            for: .normal
        )
        
        return floatingButton
    }()
    
    // Configure
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        
        configureEventListener()
        
        configureNavigationBar()
        configureTableView()
        configureRefreshControl()
        configureFloatingActionButton()
        
        populateTableView()
    }
    
    private func configureEventListener() {
        TXEventBroker.shared.listen {
            [weak self] event in
            guard let strongSelf = self else {
                return
            }
            
            if event is ComposeTweetEvent {
                strongSelf.openComposeViewController()
            }
        }
    }
    
    private func addSubviews() {
        view.addSubview(tableView)
        view.addSubview(floatingButton)
    }
    
    private func configureNavigationBar() {
        let titleImage = TXImageView(image: TXBundledImage.twitterX)
        titleImage.contentMode = .scaleAspectFit
        
        navigationItem.backButtonTitle = ""
        navigationItem.titleView = titleImage
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.addBufferOnHeader(withHeight: 0)
        

        tableView.register(
            PartialTweetTableViewCell.self,
            forCellReuseIdentifier: PartialTweetTableViewCell.reuseIdentifier
        )
        tableView.register(
            EmptyFeedTableViewCell.self,
            forCellReuseIdentifier: EmptyFeedTableViewCell.reuseIdentifier
        )
        
        tableView.pin(
            to: view,
            byBeingSafeAreaAware: true
        )
    }
    
    private func configureRefreshControl() {
        tableView.refreshControl = TXRefreshControl()
        
        tableView.refreshControl?.addTarget(
            self,
            action: #selector(onRefreshControllerChanged(_:)),
            for: .valueChanged
        )
    }
    
    private func configureFloatingActionButton() {
        floatingButton.pin(
            toBottomOf: view,
            withInset: 20,
            byBeingSafeAreaAware: true
        )
        
        floatingButton.pin(
            toRightOf: view,
            withInset: 20,
            byBeingSafeAreaAware: true
        )
        
        floatingButton.addTarget(
            self,
            action: #selector(onComposePressed(_:)),
            for: .touchUpInside
        )
    }
    
    // Populate
    
    // Interact
    @objc private func onComposePressed(_ sender: UITapGestureRecognizer) {
        openComposeViewController()
    }
    
    @objc private func onRefreshControllerChanged(_ refreshControl: TXRefreshControl) {
        populateTableView()
    }
    
    private func openComposeViewController() {
        let composeViewController = TXNavigationController(
            rootViewController: ComposeViewController()
        )
        
        composeViewController.modalPresentationStyle = .fullScreen
        
        present(composeViewController, animated: true)
    }
}

// MARK: TXTableViewDataSource
extension FeedViewController: TXTableViewDataSource {
    private func populateTableView() {
        tableView.beginPaginating()
        
        Task {
            [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            let result = await FeedDataStore.shared.feed()
            
            strongSelf.tableView.endPaginating()
            strongSelf.tableView.addBufferOnFooter(withHeight: 100)
            
            strongSelf.state = result
            strongSelf.tableView.reloadData()
            strongSelf.tableView.refreshControl?.endRefreshing()
        }
    }
    
    func numberOfSections(
        in tableView: UITableView
    ) -> Int {
        return 1
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        switch state {
        case .success(let paginated):
            if paginated.page.count > 0 {
                return paginated.page.count
            } else {
                return 1
            }
        default:
            return 0
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        switch state {
        case .success(let paginated):
            if paginated.page.count > 0 {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: PartialTweetTableViewCell.reuseIdentifier,
                    assigning: indexPath
                ) as! PartialTweetTableViewCell
                
                cell.interactionsHandler = self
                cell.configure(withTweet: paginated.page[indexPath.row])
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: EmptyFeedTableViewCell.reuseIdentifier,
                    assigning: indexPath
                ) as! EmptyFeedTableViewCell
                
                return cell
            }
        default:
            return UITableViewCell()
        }
    }
}

// MARK: TXTableViewDelegate
extension FeedViewController: TXTableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        switch state {
        case .success(let paginated):
            if paginated.page.count == 0 {
                cell.separatorInset = .leading(.infinity)
            } else if indexPath.row  == paginated.page.count - 1 {
                cell.separatorInset = .leading(.infinity)
            } else {
                cell.separatorInset = .leading(20)
            }
        default:
            break
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch state {
        case .success(let paginated):
            if paginated.page.count > 0 {
                let tweet = paginated.page[indexPath.row]
                
                let tweetViewController = TweetViewController()
                
                tweetViewController.populate(withTweet: tweet)
                
                navigationController?.pushViewController(
                    tweetViewController,
                    animated: true
                )
            }
        default:
            break
        }
    }
}

// MARK: TweetTableViewCellInteractionsHandler
extension FeedViewController: PartialTweetTableViewCellInteractionsHandler {
    func partialTweetCellDidPressLike(_ cell: PartialTweetTableViewCell) {
        print(#function)
    }
    
    func partialTweetCellDidPressComment(_ cell: PartialTweetTableViewCell) {
        switch state {
        case .success(let paginated):
            let tweet = paginated.page[cell.indexPath.row]
            
            navigationController?.openTweetViewController(
                withTweet: tweet,
                andOptions: .init(
                    autoFocus: true
                )
            )
        default:
            break
        }
    }
    
    func partialTweetCellDidPressProfileImage(_ cell: PartialTweetTableViewCell) {
        switch state {
        case .success(let paginated):
            let tweet = paginated.page[cell.indexPath.row]
            
            let user = tweet.author
            
            navigationController?.openUserViewController(withUser: user)
        default:
            break
        }
    }
    
    func partialTweetCellDidPressBookmarksOption(_ cell: PartialTweetTableViewCell) {
        print(#function)
    }
    
    func partialTweetCellDidPressFollowOption(_ cell: PartialTweetTableViewCell) {
        print(#function)
    }
    
    func partialTweetCellDidPressOptions(_ cell: PartialTweetTableViewCell) {
        switch state {
        case .success(let paginated):
            let alert = TweetOptionsAlertViewController.regular()
            
            alert.interactionsHandler = self
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

// MARK: TweetOptionsAlertViewControllerInteractionsHandler
extension FeedViewController: TweetOptionsAlertViewControllerInteractionsHandler {
    func tweetOptionsAlertViewControllerDidPressBookmark(_ controller: TweetOptionsAlertViewController) {
        print(#function)
    }
    
    func tweetOptionsAlertViewControllerDidPressFollow(_ controller: TweetOptionsAlertViewController) {
        print(#function)
    }
}

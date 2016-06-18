//
//  ViewController.swift
//  GiphySearch
//
//  Created by Kyle Fang on 6/18/16.
//  Copyright © 2016 Kyle Fang. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class HomeViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var searchController = UISearchController(searchResultsController: nil)
    
    let refreshControl = UIRefreshControl()
    
    let viewModel = Injector.resolve(ViewModel.self)
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindDataToUI()
    }
    
    private func setupUI() {
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.tableView.addSubview(refreshControl)
    }
    
    private func bindDataToUI() {
        let driver = self.viewModel.driver
        
        driver
            .map({$0.isLoading})
            .bindTo(self.refreshControl.refreshingLens)
            .addDisposableTo(self.disposeBag)
        
        driver
            .map({$0.isSearching})
            .bindTo(self.searchController.activeLens)
            .addDisposableTo(self.disposeBag)
        
        driver
            .map({$0.searchingText})
            .bindTo(self.searchController.searchBar.textLens)
            .addDisposableTo(self.disposeBag)

        
        driver
            .map({$0.data})
            .distinctUntilChanged(==)
            .drive(self.tableView.rx_itemsWithCellFactory) { tableView, index, giphy in
                return UITableViewCell()
            }
            .addDisposableTo(self.disposeBag)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
}

private extension UIRefreshControl {
    var refreshingLens: Lens<Bool> {
        return Lens(getter: {self.refreshing}, setter: {
            $0 ? self.beginRefreshing() : self.endRefreshing()
        })
    }
}

private extension UISearchController {
    var activeLens: Lens<Bool> {
        return Lens(getter: {self.active}, setter: {self.active = $0})
    }
}

private extension UISearchBar {
    var textLens: Lens<String> {
        return Lens(getter: {self.text ?? ""}, setter: {self.text = $0})
    }
}

extension Giphy: Equatable {}

func ==(left: Giphy, right: Giphy) -> Bool {
    return left.id == right.id &&
        left.images == right.images &&
        left.slug == right.slug &&
        left.url == right.url
}



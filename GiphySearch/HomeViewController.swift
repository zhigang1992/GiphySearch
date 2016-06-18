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
import YYWaterflowLayout

class HomeViewController: UIViewController, YYWaterflowLayoutDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    let waterFlowLayout = YYWaterflowLayout()
    
    let refreshControl = UIRefreshControl()
    
    let viewModel = Injector.resolve(HomeViewModel.self)
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindDataToUI()
        bindUIEventToViewModel()
    }
    
    private func setupUI() {
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        
        self.collectionView.collectionViewLayout = self.waterFlowLayout
        
        self.collectionView.addSubview(refreshControl)
        self.collectionView.alwaysBounceVertical = true
        
        self.waterFlowLayout.delegate = self
        self.waterFlowLayout.columnMargin = 10
        self.waterFlowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.waterFlowLayout.columnsCount = 2
        self.waterFlowLayout.rowMargin = 10
        
        let searchBar = self.searchController.searchBar
        self.view.addSubview(searchBar)
        let constraints: [NSLayoutConstraint] = [
            searchBar.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor),
            searchBar.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor),
            searchBar.bottomAnchor.constraintEqualToAnchor(self.collectionView.topAnchor)
        ]
        constraints.forEach({$0.active = true})
        self.view.addConstraints(constraints)
    }
    
    func waterflowLayout(waterflowLayout: YYWaterflowLayout!, heightForWidth width: CGFloat, atIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let giphy = self.viewModel.giphys.value[indexPath.row]
        return giphy.size.height / giphy.size.width * width
    }
    
    private func bindDataToUI() {
        viewModel.giphys.asDriver()
            .distinctUntilChanged(==)
            .drive(self.collectionView.rx_itemsWithCellFactory) { collectionView, index, giphy in
                let indexPath = NSIndexPath(forItem: index, inSection: 0)
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(R.reuseIdentifier.giphyCell, forIndexPath: indexPath)!
                cell.tagLabel.text = giphy.id
                return cell
            }
            .addDisposableTo(self.disposeBag)
    }
    
    private func bindUIEventToViewModel() {
        Observable.of(
            self.searchController.rx_willPresent.map({true}),
            self.searchController.rx_willDismiss.map({false})
        ).merge()
            .bindTo(viewModel.isSearching)
            .addDisposableTo(self.disposeBag)
        
        self.searchController.searchBar.rx_text
            .bindTo(self.viewModel.searchingText)
            .addDisposableTo(self.disposeBag)
        
        self.refreshControl.rx_controlEvent(.ValueChanged)
            .flatMap({[unowned self] _ in self.viewModel.refresh() })
            .doOnError({[unowned self] error in
                self.refreshControl.endRefreshing()
                let vc = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .Alert)
                self.presentViewController(vc, animated: true, completion: nil)
            })
            .retry()
            .subscribeNext({[unowned self] _ in
                self.refreshControl.endRefreshing()
            })
            .addDisposableTo(self.disposeBag)

        self.collectionView
            .rx_itemSelected
            .map({[unowned self] in self.viewModel.giphys.value[$0.row] })
            .subscribeNext({ giphy in
                if let url = NSURL(string: giphy.url) {
                    UIApplication.sharedApplication().openURL(url)
                }
            })
            .addDisposableTo(self.disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension Giphy: Equatable {}

func ==(left: Giphy, right: Giphy) -> Bool {
    return left.id == right.id &&
        left.images == right.images &&
        left.slug == right.slug &&
        left.url == right.url
}

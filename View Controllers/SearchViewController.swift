//
//  SearchViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-31.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

let TitleCellIdentifier = "TitleCell"
let SubredditCellIdentifier = "SubredditCell"
let HistoryCellIdentifier = "HistoryCell"

class SearchViewController: UIViewController {

  private var searchController: UISearchController!
  private var resultsTableView: UITableView!
  private var scopeSegmentedControl: UISegmentedControl!

    var provider: Networking!
    
    var cellIdentifier = Variable(HistoryCellIdentifier)

    var _selectedScope = Variable(0)

    lazy var viewModel: SearchViewModelType = {
        return SearchViewModel(provider: self.provider, selectedScope: self._selectedScope.asObservable())
    }()
    
    private var disposeBag = DisposeBag()

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.applyTheme), name: Notification.Name.onThemeChanged, object: nil)
        
        searchController = {
            $0.hidesNavigationBarDuringPresentation = true
            ($0.searchBar.rx.selectedScopeButtonIndex <-> _selectedScope).addDisposableTo(disposeBag)
            
            return $0
        }(UISearchController(searchResultsController: nil))
        
        resultsTableView = {
            $0.delegate = nil
            $0.dataSource = nil
            $0.tableFooterView = UIView()
            $0.tableHeaderView = searchController.searchBar
            return $0
        }(UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)))
        view.addSubview(resultsTableView)
        self.setupUI()

        // Map scope selection to cell reuse identifier
        viewModel
            .selectedScope
            .map { SearchViewModel.ScopeValues(rawValue: $0) }
            .map { scope -> String in
                switch scope! {
                case .Title:
                    return TitleCellIdentifier
                case .Subreddit:
                    return SubredditCellIdentifier
                } 
            }
            .bindTo(cellIdentifier)
            .addDisposableTo(self.disposeBag)

        searchController.searchBar.rx.text
            .asDriver()
            .throttle(0.3)
            .flatMapLatest { query in
                self.viewModel.getSearchResults(query: query!)
                    .asDriver(onErrorJustReturn: [])
            }
            .drive(resultsTableView.rx.items(cellIdentifier: cellIdentifier.value, cellType: SubredditCell.self)) { (_, subreddit, cell) in
                //cell.loadCell(subreddit)
                print("Hello")
            }
            .addDisposableTo(self.disposeBag)
        
        searchController.rx.present
            .asObservable()
            .subscribe(onNext: { _ in
                self.searchController.searchBar.scopeButtonTitles = SearchViewModel.ScopeValues.allScopeValueNames()
                print("Present")
            })
            .addDisposableTo(disposeBag)
        
        searchController.rx.willDismiss
            .asObservable()
            .subscribe(onNext: { _ in
                print("Dismiss")
            })
            .addDisposableTo(disposeBag)
        
    }
    
    func setupUI() {
        definesPresentationContext = true
        self.searchController.searchBar.searchBarStyle = .minimal
        
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = true
        
        navigationItem.title = "Discovery"
        navigationController?.navigationBar.titleTextAttributes![NSFontAttributeName] = UIFont(name: "Lato-Regular", size: 20)!
        navigationItem.backBarButtonItem  = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.applyTheme()
    }

    func applyTheme() {
        let theme = TableViewTheme()!
        self.view.backgroundColor = theme.backgroundColor
        self.resultsTableView.backgroundColor = UIColor.clear
        self.resultsTableView.separatorColor = theme.separatorColor
        self.resultsTableView.indicatorStyle = theme.indicatorStyle
    }
}

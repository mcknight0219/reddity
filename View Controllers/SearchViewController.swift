//
//  SearchViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-31.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
import RxDataSources
#endif

let TitleCellIdentifier = "TitleCell"
let SubredditCellIdentifier = "SubredditCell"
let HistoryCellIdentifier = "HistoryCell"

class SearchViewController: UIViewController {

    private var searchController: UISearchController!

    private var resultsTableView: UITableView!

    private var scopeSegmentedControl: UISegmentedControl!

    var cellIdentifier: Variable(HistoryCellIdentifier)

    lazy var viewModel: SearchViewModelType = {
        return SearchViewModel(provider: provider, selectedScope)
    }()
    
    private var disposeBag = DisposeBag()

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController = {
            $0.hidesNavigationBarDuringPresentation = false
        }(UISearchController(searchResultsController: nil))

        scopeSegmentedControl = {
            
        }(UISegmentedControl(SearchViewModel.ScopeValues.allScopeValueNames()))

        var selectedScope = Variable(0)
        scopeSegmentedControl.rx_value <-> selectedScope
        viewModel.selectedScope = selectedScope.asObservable()

        resultsTableView = {
            $0.delegate = nil
            $0.dataSource = nil
            $0.tableHeaderView = searchController.searchBar
            return $0
        }(UITableView(frame: CGRectMake(0, 0, view.frame.width, view.frame.height)))
        view.addSubview(resultsTableView)
        self.setupUI()
        
        configureTableDataSource()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchViewController.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
    }
    
    func configureTableDataSource() {
        [SubredditCellIdentifier, TitleCellIdentifier, HistoryCellIdentifier].forEach { name in
            resultsTableView.registerNib(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: name)
        }
        resultsTableView.dataSource = nil
        resultsTableView.delegate = nil
        resultsTableView.rowHeight = 44
        
        searchController.searchBar.rx_text
            .asDriver()
            .throttle(0.3)
            .distinctUntilChanged()
            .flatMapLatest { query in
                SearchAPI.sharedAPI.getSearchRestults(query)
                    .startWith([])
                    .asDriver(onErrorJustReturn: [])
            }
            .drive(resultsTableView.rx_itemsWithCellIdentifier(cellIdentifier.value, cellType: SubredditCell.self)) { (_, subreddit, cell) in
                cell.loadCell(subreddit)
            }
            .addDisposableTo(self.disposeBag)
    }
    
    func setupUI() {
        definesPresentationContext = true
        self.searchController.searchBar.searchBarStyle = .Default
        
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = true
        
        navigationItem.title = "Discovery"
        navigationController?.navigationBar.titleTextAttributes![NSFontAttributeName] = UIFont(name: "Lato-Regular", size: 20)!
        navigationItem.backBarButtonItem  = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        self.applyTheme()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func applyTheme() {
        
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            view.backgroundColor = UIColor(colorLiteralRed: 33/255, green: 34/255, blue: 45/255, alpha: 1.0)
            self.resultsTableView.backgroundColor = UIColor(colorLiteralRed: 33/255, green: 34/255, blue: 45/255, alpha: 1.0)

            self.resultsTableView.separatorColor = UIColor.darkGrayColor()
            self.resultsTableView.indicatorStyle = .White
            self.searchController.searchBar.barTintColor = UIColor(colorLiteralRed: 32/255, green: 34/255, blue: 34/255, alpha: 1.0)
            self.searchController.searchBar.tintColor = UIColor.whiteColor()
            (UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self])).tintColor = UIColor.whiteColor()
            
        } else {
            view.backgroundColor = UIColor(colorLiteralRed: 0.94, green: 0.94, blue: 0.96, alpha: 1.0)
            self.resultsTableView.backgroundColor = UIColor(colorLiteralRed: 0.94, green: 0.94, blue: 0.96, alpha: 1.0)
            
            self.resultsTableView.separatorColor = UIColor(colorLiteralRed: 0.9, green: 0.9, blue: 0.01, alpha: 1.0)
            self.resultsTableView.indicatorStyle = .Default
            self.searchController.searchBar.barTintColor = UIColor.lightGrayColor()
            self.searchController.searchBar.tintColor = UIColor.blackColor()
            (UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self])).tintColor = UIColor.blackColor()
        }
        
    }
}

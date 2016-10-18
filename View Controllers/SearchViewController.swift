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

enum TableContent {
    case History
    case Subreddit
    case Link
    case Empty
    
    var background: UIView? {
        switch self {
        case .Empty:
            let background = UIView()
            
            let image: UIImageView = {
                $0.center = CGPoint(x: UIScreen.mainScreen().bounds.width / 2, y: UIScreen.mainScreen().bounds.height / 2 - 150)
                return $0
            }(UIImageView(image: UIImage.fontAwesomeIconWithName(.Search, textColor: FlatWhiteDark(), size: CGSizeMake(50, 50))))
            background.addSubview(image)
            
            let label: UILabel = {
                $0.text = "You can search subreddits name and title"
                $0.font = UIFont(name: "Lato-Regular", size: 18)!
                $0.textColor = FlatWhiteDark()
                $0.numberOfLines = 0
                $0.textAlignment = .Center
                
                return $0
            }(UILabel())
            background.addSubview(label)
            
            label.snp_makeConstraints { make in
                make.leading.equalTo(background).offset(30)
                make.trailing.equalTo(background).offset(-30)
                make.top.equalTo(image.snp_bottom).offset(5)
            }
            
            return background
        default:
            return nil
        }
    }
    
    var footer: UIView? {
        switch self {
        case .Subreddit, .Link :
            return nil
        default:
            return nil
        }
    }
    
    var rowHeight: CGFloat {
        switch self {
        case .History:
            return 44
        default:
            return 100
        }
    }
}

class SearchViewController: UIViewController {

    private let searchController = UISearchController(searchResultsController: nil)

    var tableContent: TableContent = .History
    
    private var resultsTableView: UITableView!
    
    private var disposeBag = DisposeBag()

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        ["SubredditCell", "TitleCell"].forEach { name in
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
            .drive(resultsTableView.rx_itemsWithCellIdentifier("SubredditCell", cellType: SubredditCell.self)) { (_, subreddit, cell) in
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

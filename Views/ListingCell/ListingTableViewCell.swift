//
//  BaseTableViewCell.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-02
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import RxSwift

class ListingTableViewCell: UITableViewCell {

    // The title of link
    lazy var title: UILabel? = {
        return self.viewWithTag(1) as? UILabel
    }()
    
    lazy var subreddit: UILabel? = {
        return self.viewWithTag(4) as? UILabel
    }()

    lazy var date: UILabel? = {
       return self.viewWithTag(5) as? UILabel
    }()
    
    // Only specific to text cell
    lazy var selfText: UILabel? = {
       return self.viewWithTag(10) as? UILabel
    }()
    
    // Only specific to NewsCell and ImageCell
    lazy var picture: UIImageView? = {
        return self.viewWithTag(3) as? UIImageView
    }()
    
    // Only specific to VideoCell
    lazy var video: PlayerView? = {
        return self.viewWithTag(6) as? PlayerView
    }()

    var reuseBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    let placeholder = UIImage(named: "empty_placeholder")
    var viewModel = PublishSubject<LinkViewModel>()
    func setViewModel(viewModel: LinkViewModel) {
        self.viewModel.onNext(viewModel)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.picture?.image = self.placeholder
        self.video?.player?.replaceCurrentItem(with: nil)
        self.video?.firstTimePlay = true
        self.configure()
    }

    func configure() {
        reuseBag = DisposeBag()
        
        self.applyTheme()
        self.selectionStyle = .none
        NotificationCenter.default.addObserver(self, selector: #selector(ListingTableViewCell.applyTheme), name: Notification.Name.onThemeChanged, object: nil)
    
        // Common to all listing table view cell
        viewModel
            .map { viewModel -> String in
                return viewModel.title
            }
            .bindTo(self.title!.rx.text)
            .addDisposableTo(reuseBag)
        
        viewModel
            .map { viewModel -> String in
                return viewModel.subreddit
            }
            .bindTo(self.subreddit!.rx.text)
            .addDisposableTo(reuseBag)
        
        viewModel
            .map { viewModel -> String in
                return  viewModel.date
            }
            .bindTo(self.date!.rx.text)
            .addDisposableTo(reuseBag)
    }

    @objc private func applyTheme() {
        let theme = CellTheme()!
        self.backgroundColor      = theme.backgroundColor
        self.title?.textColor     = theme.mainTextColor
        self.subreddit?.textColor = theme.linkColor
    }
}

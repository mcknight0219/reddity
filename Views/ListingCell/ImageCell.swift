//
//  TopicCell.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-24.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif


class ImageCell: ListingTableViewCell {
    
    var tapOnPicture: Observable<NSDate>!

    var spinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.activityIndicatorViewStyle = .Gray
        view.hidesWhenStopped = true

        return view
    }()

    override func configure() {
        super.configure()
        
        self.picture?.addSubview(spinner)
        self.picture?.bringSubviewToFront(spinner)
        spinner.center = CGPoint(x: CGRectGetMidX(self.picture!.bounds) , y: CGRectGetMinX(self.picture!.bounds))
        spinner.startAnimating()
        
        let tap = UITapGestureRecognizer()
        self.picture?.addGestureRecognizer(tap)
        self.picture?.addSubview(self.spinner)
        self.spinner.center = CGPointMake(CGRectGetMidX(self.picture!.bounds), CGRectGetMidY(self.picture!.bounds))
        
        tapOnPicture = tap
            .rx_event
            .map { _ in
                return NSDate()
            }
        
        viewModel
            .map { viewModel -> NSURL? in
                return viewModel.resourceURL
            } 
            .doOn {[weak self] _ in
                self?.picture?.contentMode = .ScaleAspectFill
                self?.picture?.clipsToBounds = true
                self?.picture?.image = self?.placeholder
            }
            .map { element -> NSURL? in
                if let value = element {
                    return value
                } else {
                    return nil
                }
            }
            .subscribeNext {[weak self] URL in
                if let URL = URL {
                    self?.picture?.sd_setImageWithURL(URL, placeholderImage: self?.placeholder, completed: { [weak self] (_, _, _, _) in
                        if let weakSelf = self {
                            weakSelf.spinner.stopAnimating()
                        }
                    })
                }
            }
            .addDisposableTo(reuseBag)
    }
    
}

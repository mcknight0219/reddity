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
        view.activityIndicatorViewStyle = .gray
        view.hidesWhenStopped = true

        return view
    }()

    override func configure() {
        super.configure()
        
        self.picture?.addSubview(spinner)
        self.picture?.bringSubview(toFront: spinner)
        spinner.center = CGPoint(x: self.picture!.bounds.midX , y: self.picture!.bounds.minX)
        spinner.startAnimating()
        
        let tap = UITapGestureRecognizer()
        self.picture?.addGestureRecognizer(tap)
        self.picture?.addSubview(self.spinner)
        self.spinner.center = CGPoint(x: self.picture!.bounds.midX, y: self.picture!.bounds.midY)
        
        tapOnPicture = tap
            .rx.event
            .map { _ in
                return NSDate()
            }
        
        viewModel
            .map { viewModel -> URL? in
                return viewModel.resourceURL
            } 
            .do(onNext: {[weak self] _ in
                self?.picture?.contentMode = .scaleAspectFill
                self?.picture?.clipsToBounds = true
                self?.picture?.image = self?.placeholder
            })
            .map { element -> URL? in
                if let value = element {
                    return value
                } else {
                    return nil
                }
            }
            .subscribe(onNext: {[weak self] url in
                if let url = url {
                    self?.picture?.kf.setImage(with: url, placeholder: self?.placeholder, options: nil, progressBlock: nil, completionHandler: { _ in
                        if let weakSelf = self {
                            weakSelf.spinner.stopAnimating()
                        }
                    })
                }
            })
            .addDisposableTo(reuseBag)
    }
    
}

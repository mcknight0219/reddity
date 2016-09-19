//
//  ImageDetailViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 16/9/19.
//  Copyright © 2016年 Qiang Guo. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController {

    var url: NSURL?

    let closeButton: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.closeButton = UIImageView(frame: CGRectMake(view.frame.width - 25, 0, 25, 25))
        self.closeButton.image = UIImage.fontAwesomeIconWithName(.Times, textColor: UIColor.blackColor(), size: CGSize(width: 25, height: 25))
        
        let g = UITapGestureRecognizer(self, action: #selector(ImageDetailViewController.closeButtonTapped(_:)))
        self.closeButton.addGestureRecognizer(g)
        self.view.addSubview(self.closeButton)
    }

    /**
     Animate image frame 
     */
    override func viewDidAppear() {
        super.viewDidAppear()
    }

    private func closeButtonTapped(sender: UITapGestureRecognizer) {
        self.dismissViewControllerAnimated(true, completion: nil)    
    }
}


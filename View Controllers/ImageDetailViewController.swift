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

    var closeButton: UIImageView!
    
    init(URL: NSURL) {
        super.init(nibName: nil, bundle: nil)
        
        self.url = URL
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()

        self.closeButton = UIImageView(frame: CGRectMake(10, 25, 30, 30))
        
        self.closeButton.image = UIImage.fontAwesomeIconWithName(.Times, textColor: UIColor.whiteColor(), size: CGSize(width: 25, height: 25))
        
        let g = UITapGestureRecognizer(target: self, action: #selector(ImageDetailViewController.closeButtonTapped(_:)))
        
        self.closeButton.userInteractionEnabled = true
        self.closeButton.addGestureRecognizer(g)
        
        self.view.addSubview(self.closeButton)
        
        let imageView = UIImageView(frame: CGRectMake(0, 0, view.bounds.width, view.bounds.height))
        
        imageView.center = self.view.center
        imageView.contentMode = .ScaleAspectFit
        
        imageView.sd_setImageWithURL(url!)
        view.addSubview(imageView)
        
    }

    /**
     Animate image frame 
     */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    @objc private func closeButtonTapped(sender: UITapGestureRecognizer) {
        self.dismissViewControllerAnimated(true, completion: nil)    
    }
}


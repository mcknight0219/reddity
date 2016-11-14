//
//  ImageDetailViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 16/9/19.
//  Copyright © 2016年 Qiang Guo. All rights reserved.
//

import UIKit
#if !RX_NO_MOUDLE
import RxSwift
import RxCocoa
#endif

class ImageDetailViewController: UIViewController {

    var URL: NSURL?
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    
    var inZoomIn: Bool = false
    
    var tap = UITapGestureRecognizer()
    private var reuseBag = DisposeBag()
    
    init(URL: NSURL) {
        super.init(nibName: nil, bundle: nil)
        self.URL = URL    
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

        scrollView = {
            $0.delegate = self
            $0.backgroundColor = UIColor.clearColor()
            $0.maximumZoomScale = 4
            $0.minimumZoomScale = 0.1
            $0.bouncesZoom = false

            return $0
        }(UIScrollView(frame: self.view.bounds))
    
        self.view.addSubview(scrollView)

        imageView = {
            $0.center = self.view.center
            $0.contentMode = .Center
            $0.sd_setImageWithURL(URL)

            return $0
        }(UIImageView(frame: self.view.bounds))
        imageView.sd_setImageWithURL(URL, completed: { (image, _, _, _) in
            self.scrollView.setZoomScale(UIScreen.mainScreen().bounds.width / image.size.width, animated: true)
        })
        
        scrollView.addSubview(imageView)
        
        self.scrollView.addGestureRecognizer(tap)
        tap.rx_event
            .subscribeNext {[weak self] _ in
                self?.dismissViewControllerAnimated(true, completion: nil)
            }
            .addDisposableTo(reuseBag)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(1.5) { [weak self] in
            self?.view.alpha = 1.0
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIView.animateWithDuration(1.5) { [weak self] in
            self?.view.alpha = 0.0
        }
    }
}

// MARK: UIScrolViewDelegate

extension ImageDetailViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerImage()
    }
    
    func centerImage() {
        let originalSize = self.scrollView.bounds.size
        let contentSize  = self.scrollView.contentSize
        let offsetX = originalSize.width > contentSize.width
            ? (originalSize.width - contentSize.width) / 2
            : 0
        
        let offsetY = originalSize.height > contentSize.height
            ? (originalSize.height - contentSize.height) / 2
            : 0
        
        self.imageView.center = CGPointMake(contentSize.width / 2 + offsetX, contentSize.height / 2 + offsetY)
    }
}


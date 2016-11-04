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
    
    var tap = UITagGestureRecognizer()
    
    var swipeUp: UISwipeGestureRecognizer = {
        $0.direction = .Up
        return $0
    }(UISwipeGestureRecognizer())
    
    var swipeDown: UISwipeGestureRecognizer = {
        $0.direction = .Down
        return $0
    }(UISwipeGestureRecognizer())

    private let disposeBag = DisposeBag()
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
            $0.minimumzoomScale = 0.5
            $0.bounceZoom = true
            $0.showVerticalScrollIndicator = false
            $0.showHorizontalScrollIndicator = false

            return $0
        }(UIScrollView(frame: self.view.bounds))
        self.view.addSubview(scrollView)

        imageView = {
            $0.center = self.view.center
            $0.contentMode = .ScaleAspectFit

            return $0
        }(UIImageView(frame: self.view.bounds))
        scrollView.addSubview(imageView)

        // Setup gesture recognizer
        [tap, swipeUp, swipeDown].forEach {
            $0.addGestureRecognizer($0) 
            $0.rx_event
            .subscribeNext {[weak self] _ in
                self.dismissViewControllerAnimated(true, completion: nil)    
            }
        }        
        
        // Setup image and suitable frame
        self.imageView.sd_setImageWithURL(URL)
    }
}

// MARK: UIScrolViewDelegate

extension ImageDetailViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    } 

    func scrollViewDidZoom(scrollView: UIScrollView) {
        let originalSize = self.scrollView.bounds.size
        let contentSize  = self.scrollView.contentSize
        let offsetX = originalSize.width > contentSize.width
            ? (originalSize.width - contentSize.width) / 2
            : 0

        let offsetY = originalSize.height > contentSize.height
            ? (originalSize.height - cotnentSize.height) / 2
            : 0

        self.imageView.center = CGPointMake(contentSize.width / 2 + offsetX, contentSize.height / 2 + offsetY)
    }
}


//
//  UIImage+Reddity.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-23.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit

extension UIImage {
    class func imageFilledWithColor(color: UIColor) -> UIImage {
        
        let image: UIImage
        
        UIGraphicsBeginImageContext(CGSizeMake(1, 1))
        
        color.setFill()
        CGContextFillRect(UIGraphicsGetCurrentContext()!, CGRectMake(0, 0, 1, 1))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func resize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.drawInRect(CGRect(origin: CGPointZero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? self
    }

    func imageWithTitle(title: String, at: CGPoint) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen().scale)
        let attributes = [NSFontAttributeName: UIFont(name: "Lato-Bold", size: 15)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.drawInRect(CGRectMake(0, 0, size.width, size.heigth))
 
        height =
        UIGraphicsEndImageContext()
    }
}

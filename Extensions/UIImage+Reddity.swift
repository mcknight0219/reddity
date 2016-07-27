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
        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, 1, 1))
        image = UIGraphicsGetImageFromCurrentImageContext()
        
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
}

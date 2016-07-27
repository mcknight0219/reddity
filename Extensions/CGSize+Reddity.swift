//
//  CGSize+Reddity.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-19.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit

extension CGSize {
    var aspectRatio: CGFloat {
        if height == 0 {
            return 1
        }
        
        return width / height
    }
    
    func sizeConstraintedBySize(size: CGSize) -> CGSize {
        let aspectWidth = round(aspectRatio * size.height)
        let aspectHeight = round(size.width / aspectRatio)
        
        if aspectWidth > size.width {
            return CGSize(width: size.width, height: aspectHeight)
        } else {
            return CGSize(width: aspectWidth, height: size.height)
        }
    }
    
    func sizeFillingSize(size: CGSize) -> CGSize {
        let aspectWidth = round(aspectRatio * size.height)
        let aspectHeight = round(size.width / aspectRatio)
        
        if aspectWidth > size.width {
            return CGSize(width: aspectWidth, height: size.height)
        } else {
            return CGSize(width: size.width, height: aspectHeight)
        }
    }
}
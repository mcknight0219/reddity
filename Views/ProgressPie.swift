//
//  ProgressPie.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-24.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit

class ProgressPieView: UIView {
    /**
     The current progress to show 

     @discussion this value is between `0.0` and `1.0` inclusive
     */
     var progress: CGFloat = 0.0 {
         get {
             return progress
         }

         set {
             progress = newValue < 0 ? 0 : (newValue > 1 ? 1 : newValue)
             self.setNeedsDisplay()
         }
     }

    /**
     The outer border width.
     */
     var borderWidth: CGFloat = 2.0 {
         didSet { self.setNeedsDisplay() }
     }

    /**
     The outer border color.
     */
     var borderColor: UIColor = UIColor(red: 0.612, green: 0.710, blue: 0.839, alpha: 1.0) {
         didSet { self.setNeedsDisplay() }
     }

    /**
     The innser border width
     */
     var innnerBorderWidth: CGFloat = 2.0 {
         didSet { self.setNeedsDisplay() }
     }

    /**
     The inner border color.
     */
     var innderBorderColor: UIColor(red: 0.612, green: 0.710, blue: 0.839, alpha: 1.0) {
         didSet { self.setNeedsDisplay() }
     }

    /**
     The fill color.
     */
     var fillColor: UIColor = UIColor(red: 0.612, green: 0.710, blue: 0.839, alpha: 1.0) {
         didSet { self.setNeedsDisplay() }
     }

    /**
     The background color.
     */
     var pieBackgroundColor: UIColor = UIColor.whiteColor() {
         didSet { self.setNeedsDisplay() }
     }

    override init(coder: NSCoder) {
        super.init(coder: coder)
    } 

    override init(frame: CGRect) {
        super.init(frame: frame)   
    }

    func commonInitialize() {
        self.backgroundColor = UIColor.clearColor()
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let context = UIGraphicsGetCurrentContext()
        
        // Draw the circle
        pieBackgroundColor.set() 
        CGContextFillEllipseInRect(context, rect)
        
        func degreeToRadians(aDegree: Double) -> Double {
            return aDegree * M_PI / 180
        }

        let center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
        let radius = center.y
        let angle = degreeToRadians((360.0 * self.progress) - 90.0)
        let points = [
            CGPointMake(center.x, 0.0)
            center,
            CGPointMake(center.x + radius * cosf(angle), center.y + radius * sinf(angle))
        ]

        // Fill the finished portion, namely the pie
        self.fillColor.set()
        if (self.progress > 0) {
            CGContextAddLines(context, points, points.count)
            CGContextAddArc(context, center.x, center.y, radius, degreeToRadians(-90), angle, false)
            CGContextDrawPath(context, .EOFill)
        }

        if (self.progress < 0.99 && self.innerBorderWidth > 0) {
            self.innerBorderColor.set()
            CGContextAddLines(context, points, points.count)
            CGContextDrawPath(context, .Stroke)
        }

        if self.borderWidth > 0 {
            self.borderColor.set()
            CGContextSetLineWidth(context, self.borderWidth)
            let innerRect = CGRectMake(self.borderWidth / 2, self.borderWidth / 2, rect.size.width - self.borderWidth, rect.size.height - self.borderWidth) 
            CGContextStrokeEllipseInRect(context, innerRect)
        }
    }
}


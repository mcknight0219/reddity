import UIKit

class PlayButton: UIButton {
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)

        let originX = bounds.size.width / 4
        let buttonBounds = CGRectMake(originX, bounds.size.height / 4, bounds.size.width / 2, bounds.size.height / 2)
        let widthHeight = buttonBounds.size.width

        // Adjust rect if not square
        if bounds.size.width < bounds.size.height {

        }

        if bounds.size.width > bounds.size.height {

        }

        let context = UIGraphicsGetCurrentContext()

        // Draw Circle
        let ovalPath = UIBezierPath(ovalIn: buttinBounds)
        UIColor.whiteColor().colorWithAlphaComponent(0.5).setFill()
        ovalPath.fill()
        
        CGContextSaveGState(context)
        let triPath = UIBezierPath()
        triPath.moveToPoint(CGPointMake(originX + widthHeight / 3, bounds.size.height/4 + (bounds.size.height/2)/4))
        triPath.addLineToPoint(CGPointMake(originX + widthHeight / 3, bounds.size.height - bounds.size.height/4 - (bounds.size.height/2)/4))
        triPath.addLineToPoint(CGPointMake(bounds.size.width - originX -widthHeight/4, bounds.size.height/2))

        triPath.closePath()
        UIColor.whiteColor().colorWithAlphaComponent(0.9).setFill()
        triPath.fill()
        
        CGContextRestoreGState(context)
    }
}

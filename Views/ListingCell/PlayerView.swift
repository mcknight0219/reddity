import UIKit
import AVFoundation
import SnapKit
import ChameleonFramework

class PlayerView: UIView {
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }

    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    lazy var spinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView() 
        view.activityIndicatorViewStyle = .Gray
        view.hidesWhenStopped = true

        return view
    }()

    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.whiteColor()
        label.font = label.font.fontWithSize(12)
        label.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.65)
        label.clipsToBounds = true
        
        return label
    }()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(spinner)
        spinner.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds))
        spinner.startAnimating()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }

    func stopAnimate() {
        self.spinner.stopAnimating()
    }
}

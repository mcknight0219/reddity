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
        view.activityIndicatorViewStyle = .WhiteLarge
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
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.backgroundColor = FlatWhite().CGColor
        self.addSubview(spinner)
        self.bringSubviewToFront(spinner)
        spinner.snp_makeConstraints(closure: { make in
            make.center.equalTo(self)
        })
        
        spinner.startAnimating()
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 35))
        label.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.45)
        label.text = "mp4"
        label.font = UIFont(name: "Helvetica Neue", size: 15)
        label.layer.cornerRadius = 7.0
        label.layer.masksToBounds = true
        label.textColor = UIColor.whiteColor()
        
        self.addSubview(label)
        label.snp_makeConstraints(closure: { make in
            make.left.equalTo(self).offset(10)
            make.bottom.equalTo(self).offset(-5)
        })
    }

    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }

    func stopAnimate() {
        self.spinner.stopAnimating()
    }
}

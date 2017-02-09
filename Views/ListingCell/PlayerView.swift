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

    lazy var playButton: UIButton = {
        let button = UIButton(frame: CGRectMake(0, 0, 50, 50))
        button.setImage(UIImage(named: "play_button") , forState: .Normal)
        button.setImage(UIImage(named: "play_button_pressed"), forState: .Highlighted)
        button.addTarget(self, action: #selector(PlayerView.playVideo), forControlEvents: .TouchUpInside)
        
        return button
    }()
    
    lazy var countTimeLabel: PlaytimeLabel = {
        let label = PlaytimeLabel(frame: CGRect(x: 0, y: 0, width: 75, height: 35))
        label.delegate = self
        
        return label
    }()
    
    var firstTimePlay: Bool = true

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.backgroundColor = FlatWhite().CGColor
        self.addSubview(spinner)
        spinner.snp_makeConstraints(closure: { make in
            make.center.equalTo(self)
        })
        spinner.startAnimating()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlayerView.rewind), name: AVPlayerItemDidPlayToEndTimeNotification, object: player?.currentItem)
    }
    
    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }

    func stopAnimate() {
        self.spinner.stopAnimating()
    }

    func playOrReplay() {
        if firstTimePlay {
            firstTimePlay = false
            playVideo()
            return
        }
        
        self.addSubview(playButton)
        playButton.snp_makeConstraints(closure: { make in
            make.center.equalTo(self)
        })
        
    }
    
    func playVideo() {
        playButton.removeFromSuperview()
        
        addSubview(countTimeLabel)
        countTimeLabel.snp_makeConstraints(closure: { make in
            make.left.equalTo(self).offset(10)
            make.bottom.equalTo(self).offset(-5)
        })
        
        player?.play()
    }
    
    func rewind() {
        if firstTimePlay { return }
        player?.seekToTime(kCMTimeZero, completionHandler: { _ in
        })
    }
}

extension PlayerView: PlaytimeLabelProtocol {
    func updateText(for label: UILabel) {
        if let label = label as? PlaytimeLabel {
            
        }
    }
}

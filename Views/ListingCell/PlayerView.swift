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
        view.activityIndicatorViewStyle = .whiteLarge
        view.hidesWhenStopped = true

        return view
    }()

    lazy var playButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.setImage(UIImage(named: "play_button") , for: .normal)
        button.setImage(UIImage(named: "play_button_pressed"), for: .highlighted)
        button.addTarget(self, action: #selector(PlayerView.playVideo), for: .touchUpInside)
        
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
        
        self.layer.backgroundColor = FlatWhite().cgColor
        self.addSubview(spinner)
        spinner.snp.makeConstraints({ make in
            make.center.equalTo(self)
        })
        
        spinner.startAnimating()
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerView.rewind), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
    override class var layerClass: AnyClass {
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
        playButton.snp.makeConstraints({ make in
            make.center.equalTo(self)
        })
        
    }
    
    func playVideo() {
        playButton.removeFromSuperview()
        
        addSubview(countTimeLabel)
        countTimeLabel.snp.makeConstraints({ make in
            make.left.equalTo(self).offset(10)
            make.bottom.equalTo(self).offset(-5)
        })
        
        player?.play()
    }
    
    func rewind() {
        if firstTimePlay { return }
        player?.seek(to: kCMTimeZero, completionHandler: { _ in
        })
    }
}

extension PlayerView: PlaytimeLabelProtocol {
    func updateText(for label: UILabel) {
        if label is PlaytimeLabel {
            
        }
    }
}

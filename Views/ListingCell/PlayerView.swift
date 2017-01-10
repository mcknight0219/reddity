import UIKit
import AVFoundation
import SnapKit

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

    lazy var timeLabel: UILabel {
        let label = UILabel(frame: CGRectMake())
        label.layer.corderRadius = 10
        label.font = label.font.fontWithSize(9)
        label.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.75)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(timeLabel)
        timeLabel.snp_makeConstraints { make in
            make.leading.equalTo(10)
            make.bottom.equalTo(-5)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}

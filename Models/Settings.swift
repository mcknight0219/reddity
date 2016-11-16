import Foundation

enum TypeSizeType: String {
    case Small  = "Small"
    case Medium = "Medium"
    case Large  = "Large"
}

enum ThemeType {
    case Dark
    case Light
}

enum VideoAutoplayType: String {
    case Both = "WiFi and Cellular"
    case WiFiOnly = "WiFi only"
    case None = "Do not autoplay"
}

struct Settings {
    enum DefaultsKeys: String {
        case NSFW  = "kNSFW"
        case Theme = "kTheme"
        case TypeSize = "kTypeSize"
        case VideoAutoplay = "kVideoAutoplay"
    }

    let defaults: NSUserDefaults

    init(defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) {
        self.defaults = defaults
    }

    var nsfw: Bool {
        get {
            if let v = defaults.integerForKey(DefaultsKeys.NSFW.rawValue) {
                return v == 1
            }
            return false
        }
        set(newValue) {
            guard newValue != self.nsfw else {
                return
            } 
            defaults.setObject(newValue ? 2 : 1, forKey: Defaults.NSFW.rawValue)
        }
    }

    var videoAutoplay: VideoAutoplayType {
        get {
            if let v = defaults.integerForKey(DefaultsKeys.VideoAutoplay.rawValue) {
                return v == 1 ? .Both : (v == 2 ? .WiFiOnly : .None) 
            }
            return .None
        }
        set(newValue) {
            guard newValue != videoAutoplay else {
                return
            } 
            switch newTypeSize {
            case .Both:
                defaults.setObject(1, forKey: DefaultsKeys.VideoAutoplay.rawValue)
            case .WiFiOnly:
                defaults.setObject(2, forKey: DefaultsKeys.VideoAutoplay.rawValue)
            case .None:
                defaults.setObject(3, forKey: DefaultsKeys.VideoAutoplay.rawValue)
            }

        }
    }

    var typeSize: TypeSizeType {
        get {
            if let v = defaults.integerForKey(DefaultsKeys.TypeSize.rawValue) {
                return v == 1 ? .Small
                    : (v == 2 ? .Medium : Large)
            }
            return .Medium
        }
        set(newTypeSize) {
            guard newTypeSize != typeSize else {
                return
            }
            switch newTypeSize {
            case .Small:
                defaults.setObject(1, forKey: DefaultsKeys.TypeSize.rawValue)
            case .Medium:
                defaults.setObject(2, forKey: DefaultsKeys.TypeSize.rawValue)
            case .Large:
                defaults.setObject(3, forKey: DefaultsKeys.TypeSize.rawValue)
            }
        }
    }

    var theme: ThemeType {
        get {
            if let v = defaults.integerForKey(DefaultsKeys.Theme.rawValue) {
                return v == 1 
                    ? .Light
                    : .Dark
            }
            // If something is wrong, use Light theme
            return .Light
        }
        set(newTheme) {
            guard newTheme != theme else {
                return
            }

            switch newTheme {
            case .Light:
                defaults.setObject(1, forKey: DefaultsKeys.Theme.rawValue)
            case .Dark:
                defaults.setObject(2, forKey: DefaultsKeys.Theme.rawValue)
            }
        }
    }
}

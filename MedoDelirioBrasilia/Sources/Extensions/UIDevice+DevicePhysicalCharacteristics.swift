import UIKit

extension UIDevice {

    static var is4InchDevice: Bool {
        let model = UIDevice.modelName
        return model == "iPhone SE" || model == "iPod touch (7th generation)" || model == "Simulator iPod touch (7th generation)"
    }
    
    static var is4Point7InchDevice: Bool {
        return UIScreen.main.bounds.size.width == 375
    }
    
    static var isiPadMini: Bool {
        let model = UIDevice.modelName
        return model.contains("iPad mini")
    }

}

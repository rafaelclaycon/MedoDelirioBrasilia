import UIKit

extension UIDevice {

    static var is4InchDevice: Bool {
        let model = UIDevice.modelName
        return model == "iPhone SE" || model == "iPod touch (7th generation)" || model == "Simulator iPod touch (7th generation)"
    }
    
    static var isiPadMini: Bool {
        let model = UIDevice.modelName
        return model.contains("iPad mini")
    }
    
    static var hasDynamicIsland: Bool {
        let model = UIDevice.modelName
        return model.contains("14 Pro")
    }

}

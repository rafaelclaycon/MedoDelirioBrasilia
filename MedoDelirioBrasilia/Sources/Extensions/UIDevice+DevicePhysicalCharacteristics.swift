import UIKit

extension UIDevice {

    static var is4InchDevice: Bool {
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            return false
        }
        return UIScreen.main.bounds.width == 320
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

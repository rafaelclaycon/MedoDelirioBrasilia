import UIKit

extension UIDevice {

    static var is4InchDevice: Bool {
        return false
    }
    
    static var isiPadMini: Bool {
        let model = UIDevice.modelName
        return model.contains("iPad mini")
    }
    
    static var isMac: Bool {
        ProcessInfo.processInfo.isiOSAppOnMac
    }

}

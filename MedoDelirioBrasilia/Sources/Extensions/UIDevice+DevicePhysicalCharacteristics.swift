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
    
    static var isMac: Bool {
        ProcessInfo.processInfo.isiOSAppOnMac
    }

}

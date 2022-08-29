import Foundation
import UIKit

/// The alternate app icons available for this app to use.
///
/// These raw values match the names in the app's project settings under
/// `ASSETCATALOG_COMPILER_APPICON_NAME` and `ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES`.
enum Icon: String, CaseIterable, Identifiable {

    case primary              = "AppIcon"
    case odioNojo             = "AppIcon-OdioNojo"
    case terrivelEdit         = "AppIcon-TerrivelEdit"
    case teuCu                = "AppIcon-TeuCu"
    case boraPassarRaiva      = "AppIcon-BoraPassarRaiva"
    case malditosMilicosBlack = "AppIcon-MalditosMilicos-Black"
    case malditosMilicosRed   = "AppIcon-MalditosMilicos-Red"
    case bomDiaBoaTarde       = "AppIcon-BomDiaBoaTarde"
    case medoDelicia          = "AppIcon-MedoDelicia"
    case lgbt                 = "AppIcon-LGBT"
    
    var id: String { self.rawValue }
    var marketingName: String {
        switch self {
        case .primary:
            return "Padrão"
        case .odioNojo:
            return "Ódio e Nojo"
        case .terrivelEdit:
            return "O Terrível Editorialista do Estadão"
        case .teuCu:
            return "Teu Cu"
        case .boraPassarRaiva:
            return "Bora Passar Raiva?"
        case .malditosMilicosBlack:
            return "Malditos Milicos (Preto)"
        case .malditosMilicosRed:
            return "Malditos Milicos (Vermelho)"
        case .bomDiaBoaTarde:
            return "Bom dia, boa tarde, boa noite... por enquanto"
        case .medoDelicia:
            return "Medo e Delícia"
        case .lgbt:
            return "Orgulho"
        }
    }
    var isOffensive: Bool {
        switch self {
        case .primary:
            return false
        case .odioNojo:
            return false
        case .terrivelEdit:
            return true
        case .teuCu:
            return true
        case .boraPassarRaiva:
            return false
        case .malditosMilicosBlack:
            return true
        case .malditosMilicosRed:
            return true
        case .bomDiaBoaTarde:
            return false
        case .medoDelicia:
            return false
        case .lgbt:
            return false
        }
    }

}

class AppIcon: ObservableObject, Equatable {

    @Published var appIcon: Icon = .primary
    
    static func == (lhs: AppIcon, rhs: AppIcon) -> Bool {
        return lhs.appIcon == rhs.appIcon
    }
    
    /// Change the app icon.
    /// - Tag: setAlternateAppIcon
    func setAlternateAppIcon(icon: Icon) {
        // Set the icon name to nil to use the primary icon.
        let iconName: String? = (icon != .primary) ? icon.rawValue : nil
        
        // Avoid setting the name if the app already uses that icon.
        guard UIApplication.shared.alternateIconName != iconName else { return }
        
        UIApplication.shared.setAlternateIconName(iconName) { (error) in
            if let error = error {
                print("Failed request to update the app’s icon: \(error)")
            }
        }
        
        appIcon = icon
    }
    
    /// Initializes the model with the current state of the app's icon.
    init() {
        let iconName = UIApplication.shared.alternateIconName
        
        if iconName == nil {
            appIcon = .primary
        } else {
            appIcon = Icon(rawValue: iconName!)!
        }
    }

}

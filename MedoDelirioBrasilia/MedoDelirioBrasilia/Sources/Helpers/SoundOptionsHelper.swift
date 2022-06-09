import UIKit

class SoundOptionsHelper {

    static func suggestOtherAuthorName(soundId: String, soundTitle: String, currentAuthorName: String) {
        guard let emailSubject = "Sugestão de Outro Nome de Autor Para \(soundTitle)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        guard let emailMessage = "Nome de autor antigo: \(currentAuthorName)\nNovo nome de autor: \n\nID do conteúdo: \(soundId) (para uso interno)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        let mailToString = "mailto:medodeliriosuporte@gmail.com?subject=\(emailSubject)&body=\(emailMessage)"
        
        guard let mailToUrl = URL(string: mailToString) else {
            return
        }
        
        UIApplication.shared.open(mailToUrl)
    }

}

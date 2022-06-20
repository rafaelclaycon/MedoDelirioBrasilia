import UIKit

class SoundOptionsHelper {

    static func isSelectedSoundOfUnknownAuthor(authorId: String) -> Bool {
        return authorId == "40947930-E7D9-45A7-991B-DB8F8CC0BA01"
    }
    
    static func getSuggestOtherAuthorNameButtonTitle(authorId: String) -> String {
        return isSelectedSoundOfUnknownAuthor(authorId: authorId) ? "🙋  Eu Sei o Nome do Autor!" : "Sugerir Outro Nome de Autor"
    }
    
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

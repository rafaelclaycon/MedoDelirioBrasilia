import UIKit

class SoundOptionsHelper {

    static func isSelectedSoundOfUnknownAuthor(authorId: String) -> Bool {
        return authorId == "40947930-E7D9-45A7-991B-DB8F8CC0BA01"
    }
    
    static func getSuggestOtherAuthorNameButtonTitle(authorId: String) -> String {
        return isSelectedSoundOfUnknownAuthor(authorId: authorId) ? "🙋  Eu Sei o Nome do Autor!" : "Sugerir Outro Nome de Autor"
    }

}

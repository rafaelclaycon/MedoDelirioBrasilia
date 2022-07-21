import SwiftUI

struct MedelinderView: View {

    @State private var instagramHandle: String = ""
    @State private var twitterHandle: String = ""
    
    var body: some View {
        Form {
            Section {
                Text("Bem-vindo ao Medelinder, o Tinder do Medo e Delírio!\n\nPara participar, forneça as suas informações abaixo.\n\nVocê poderá ver as @s de uma pessoa que possa se interessar por você 1 vez por dia.")
            }
            
            Section {
                TextField("Instagram", text: $instagramHandle)
                    .disableAutocorrection(true)
                
                TextField("Twitter", text: $twitterHandle)
                    .disableAutocorrection(true)
            }
            
//            Section {
//                
//            }
        }
    }

}

struct MedelinderView_Previews: PreviewProvider {

    static var previews: some View {
        MedelinderView()
    }

}

import SwiftUI

struct EmptyFolderView: View {

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Image(systemName: "speaker.zzz")
                .font(.system(size: 70))
                .foregroundColor(.green)
                .frame(width: 100)
            
            Text("Tá Ouvindo Isso?")
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Nós também não. Volte para a aba Sons, segure em um som e escolha Adicionar a Pasta para adicionar ele aqui.")
                .multilineTextAlignment(.center)
        }
    }

}

struct EmptyFolderView_Previews: PreviewProvider {

    static var previews: some View {
        EmptyFolderView()
    }

}

import SwiftUI

struct SoundHelpView: View {
    
    private let iconFrameWidth: CGFloat = 40

    var body: some View {
        VStack {
            ScrollView {                
                VStack(alignment: .leading, spacing: 30) {
                    HStack(alignment: .center, spacing: 15) {
                        Image(systemName: "play.fill")
                            .font(.largeTitle)
                            .foregroundColor(.accentColor)
                            .frame(width: iconFrameWidth)
                        
                        Text("Para reproduzir um som, basta tocar nele.")
                    }
                    
                    HStack(alignment: .center, spacing: 15) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.largeTitle)
                            .foregroundColor(.accentColor)
                            .frame(width: iconFrameWidth)
                        
                        Text("Para compartilhar, segure o som por 2 segundos e então escolha Compartilhar.")
                    }
                    
                    Divider()
                    
                    HStack(alignment: .center, spacing: 15) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.accentColor)
                            .frame(width: iconFrameWidth)
                        
                        Text("Para pesquisar, vá até o topo da lista e **puxe mais um pouco para baixo** até revelar o campo de pesquisa.\n\nA pesquisa considera o **conteúdo do áudio** e o **nome do autor**. Não use vírgulas.")
                    }
                    
                    Divider()
                    
                    HStack(alignment: .center, spacing: 15) {
                        Image(systemName: "star.fill")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                            .frame(width: iconFrameWidth)

                        Text("Para favoritar, segure o som por 2 segundos e então escolha **Adicionar aos Favoritos**.\n\nPara ver apenas os favoritos, toque em **Todos** no topo da tela anterior e escolha **Favoritos**.\n\nÉ possível pesquisar entre os favoritos usando a barra de Busca. Para isso, na lista de favoritos, vá até o topo e puxe mais um pouco para baixo para ver a barra.")
                    }
                    .padding(.bottom, 15)
                }
                .padding()
            }
        }
        .navigationTitle("Ajuda")
    }

}

struct SoundHelpView_Previews: PreviewProvider {

    static var previews: some View {
        SoundHelpView()
    }

}

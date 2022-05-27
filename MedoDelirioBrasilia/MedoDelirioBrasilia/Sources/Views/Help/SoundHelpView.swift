import SwiftUI

struct SoundHelpView: View {
    
    private let iconFrameWidth: CGFloat = 40

    var body: some View {
        VStack {
            ScrollView {                
                VStack(alignment: .leading, spacing: 40) {
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
                    
                    HStack(alignment: .center, spacing: 15) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.accentColor)
                            .frame(width: iconFrameWidth)
                        
                        VStack(spacing: 15) {
                            Text("Para pesquisar, vá até o topo da lista e **puxe mais um pouco para baixo** até revelar o campo de pesquisa.")
                            Text("A pesquisa considera o **conteúdo do áudio** e o **nome do autor**.")
                        }
                    }
                    
                    HStack(spacing: 15) {
                        Image(systemName: "star.fill")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                            .frame(width: iconFrameWidth)

                        Text("Para favoritar, segure o som por 2 segundos e então escolha Adicionar aos Favoritos.")
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Ajuda")
    }

}

struct SoundHelpView_Previews: PreviewProvider {

    static var previews: some View {
        SoundHelpView()
    }

}

import SwiftUI

struct HelpAboutView: View {
    
    private let iconFrameWidth: CGFloat = 40

    var body: some View {
        VStack {
            ScrollView {                
                VStack(alignment: .center, spacing: 40) {
                    HStack(spacing: 15) {
                        Image(systemName: "play.fill")
                            .font(.largeTitle)
                            .foregroundColor(.accentColor)
                            .frame(width: iconFrameWidth)
                        
                        Text("Para reproduzir um som, basta tocar em um dos cards da tela anterior.")
                    }
                    
                    HStack(spacing: 15) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.largeTitle)
                            .foregroundColor(.accentColor)
                            .frame(width: iconFrameWidth)
                        
                        //Text("Para compartilhar, segure o card do som por 2 segundos e então escolha Compartilhar.")
                        Text("Para compartilhar, segure o card do som por 2 segundos e então escolha o app pelo qual deseja enviá-lo.")
                    }
                    
                    HStack(spacing: 15) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.accentColor)
                            .frame(width: iconFrameWidth)
                        
                        VStack(spacing: 15) {
                            Text("Para pesquisar, vá até o topo da lista e **puxe mais um pouco para baixo** até revelar o campo de pesquisa.")
                            Text("A pesquisa considera o **conteúdo** do áudio e o **autor**.")
                        }
                    }
                    
//                    HStack(spacing: 15) {
//                        Image(systemName: "star.fill")
//                            .font(.largeTitle)
//                            .foregroundColor(.red)
//                            .frame(width: iconFrameWidth)
//
//                        Text("Para favoritar um som, segure o card do som escolhido por 2 segundos e então escolha Favoritar.")
//                    }
                }
            }
        }
        .padding()
        .navigationTitle("Ajuda")
    }

}

struct HelpAboutView_Previews: PreviewProvider {

    static var previews: some View {
        HelpAboutView()
    }

}

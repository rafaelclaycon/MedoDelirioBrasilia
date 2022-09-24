import SwiftUI

struct SongHelpView: View {
    
    private let iconFrameWidth: CGFloat = 40
    
    private var playInstruction: String {
        if ProcessInfo.processInfo.isMacCatalystApp {
            return "Para reproduzir uma música, clique nela 1 vez. Para parar de reproduzir, clique nela novamente."
        } else {
            return "Para reproduzir uma música, toque nela 1 vez. Para parar de reproduzir, toque nela novamente."
        }
    }
    
    private var shareInstruction: String {
        if ProcessInfo.processInfo.isMacCatalystApp {
            return "Para compartilhar, clique e segure a música por alguns segundos. Não se assuste, é normal que apareça uma tela vazia. As opções de compartilhamento aparecerão em um dos cantos da janela. Para sair sem compartilhar, toque em qualquer lugar da tela."
        } else {
            return "Para compartilhar, toque e segure a música por alguns segundos e então escolha o app pelo qual deseja enviá-la."
        }
    }
    
    private var searchInstruction: String {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return "Para pesquisar, vá até o topo da lista e puxe mais um pouco para baixo até revelar o campo de pesquisa.\n\nA pesquisa considera apenas o título da música."
        case .pad:
            return "Para pesquisar, toque no campo Buscar no canto superior direito da tela de músicas e digite o texto que procura.\n\nA pesquisa considera apenas o título da música."
        default:
            return "Para pesquisar, clique no campo Buscar no canto superior direito da tela de músicas e digite o texto que procura.\n\nA pesquisa considera apenas o título da música."
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            HStack(alignment: .center, spacing: 15) {
                Image(systemName: "play.fill")
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                    .frame(width: iconFrameWidth)
                
                Text(playInstruction)
            }
            
            HStack(alignment: .center, spacing: 15) {
                Image(systemName: "square.and.arrow.up")
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                    .frame(width: iconFrameWidth)
                
                Text(shareInstruction)
            }
            
            HStack(alignment: .center, spacing: 15) {
                Image(systemName: "magnifyingglass")
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                    .frame(width: iconFrameWidth)
                
                Text(searchInstruction)
            }
        }
    }

}

struct SongHelpView_Previews: PreviewProvider {

    static var previews: some View {
        SongHelpView()
    }

}

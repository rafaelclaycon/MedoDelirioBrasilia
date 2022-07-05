import SwiftUI

struct SongHelpView: View {
    
    private let iconFrameWidth: CGFloat = 40

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            HStack(alignment: .center, spacing: 15) {
                Image(systemName: "play.fill")
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                    .frame(width: iconFrameWidth)
                
                Text("Para reproduzir uma música, basta tocar nela.")
            }
            
            HStack(alignment: .center, spacing: 15) {
                Image(systemName: "square.and.arrow.up")
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                    .frame(width: iconFrameWidth)
                
                Text("Para compartilhar, segure a música por 2 segundos e então escolha o app pelo qual deseja enviá-la.")
            }
            
            HStack(alignment: .center, spacing: 15) {
                Image(systemName: "magnifyingglass")
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                    .frame(width: iconFrameWidth)
                
                Text("Para pesquisar, vá até o topo da lista e **puxe mais um pouco para baixo** até revelar o campo de pesquisa.\n\nA pesquisa considera apenas o título da música.")
            }
        }
    }

}

struct SongHelpView_Previews: PreviewProvider {

    static var previews: some View {
        SongHelpView()
    }

}

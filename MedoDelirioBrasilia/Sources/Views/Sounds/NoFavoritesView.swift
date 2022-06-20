import SwiftUI

struct NoFavoritesView: View {

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Image(systemName: "star.fill")
                .font(.system(size: 70))
                .foregroundColor(.red)
                .frame(width: 100)
            
            Text("Nenhum Favorito")
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Adicione um som aos favoritos segurando nele por 2 segundos e então escolhendo Adicionar aos Favoritos.")
                .multilineTextAlignment(.center)
        }
    }

}

struct NoFavoritesView_Previews: PreviewProvider {

    static var previews: some View {
        NoFavoritesView()
    }

}

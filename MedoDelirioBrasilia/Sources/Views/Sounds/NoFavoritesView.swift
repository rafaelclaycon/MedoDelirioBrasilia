import SwiftUI

struct NoFavoritesView: View {

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Image(systemName: "star")
                .font(.system(size: 70))
                .foregroundColor(.red)
                .frame(width: 100)
            
            Text("Nenhum Favorito")
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Para adicionar um som aos Favoritos, volte para os sons, segure em um deles e escolha Adicionar aos Favoritos.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

}

struct NoFavoritesView_Previews: PreviewProvider {

    static var previews: some View {
        NoFavoritesView()
    }

}

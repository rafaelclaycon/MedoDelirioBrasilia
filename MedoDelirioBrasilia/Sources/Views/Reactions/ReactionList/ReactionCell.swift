//
//  CollectionCell.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI
import Kingfisher

struct ReactionCell: View {

    @State var title: String
    @State var imageURL: String
    
    let regularGradient = LinearGradient(gradient: Gradient(colors: [.green, .green, .brightYellow]), startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        ZStack {
            KFImage(URL(string: imageURL))
                .placeholder {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 35)
                        .foregroundColor(.gray)
                }
                .resizable()
                .scaledToFill()
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            
//            RoundedRectangle(cornerRadius: 20, style: .continuous)
//                .fill(regularGradient)
//                .frame(width: 180)
//                .opacity(0.5)
            
            Text(title)
                .foregroundColor(.white)
                .font(.title2)
                .bold()
                .shadow(color: .black, radius: 10, y: 1)
        }
    }

}

struct ReactionCell_Previews: PreviewProvider {

    static var previews: some View {
        ReactionCell(title: "LGBTQIAP+", imageURL: "http://blog.saude.mg.gov.br/wp-content/uploads/2021/06/28-06-lgbt.jpg")
        ReactionCell(title: "Clássicos", imageURL: "https://www.avina.net/wp-content/uploads/2019/06/Confiamos-no-Brasil-e-nos-brasileiros-e-brasileiras.jpg")
        ReactionCell(title: "Sérios", imageURL: "https://images.trustinnews.pt/uploads/sites/5/2019/10/tres-tabus-que-o-homem-atual-ja-ultrapassou-2.jpeg")
        ReactionCell(title: "Invasão Foro", imageURL: "https://i.scdn.co/image/0a32a3b9a4f798833f1c10aac18197f7b119e758")
    }

}

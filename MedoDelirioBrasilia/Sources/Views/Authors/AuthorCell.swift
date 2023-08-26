//
//  AuthorCell.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 18/07/22.
//

import SwiftUI
import Kingfisher

struct AuthorCell: View {

    @State var authorName: String
    @State var authorImageURL: String
    @State var soundCount: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.gray)
                .frame(height: UIDevice.is4InchDevice ? 120 : 96)
                .opacity(colorScheme == .dark ? 0.25 : 0.15)
            
            HStack {
                if authorImageURL.isEmpty == false {
                    KFImage(URL(string: authorImageURL))
                        .placeholder {
                            Image(systemName: "person.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 50)
                                .foregroundColor(.gray)
                                .opacity(0.3)
                        }
                        .resizable()
                        .scaledToFit()
                        .frame(width: 55)
                        .clipShape(Circle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(authorName)
                        .foregroundColor(.primary)
                        .bold()
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                .padding(.leading, 5)
                
                Spacer()

                NumberBadgeView(number: soundCount, showBackgroundCircle: true)
                    .foregroundColor(.primary)
                    .padding(.trailing, 10)

                Image(systemName: "chevron.right")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .frame(height: 16)
            }
            .padding(.leading)
            .padding(.trailing)
        }
    }

}

struct AuthorCell_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            // No image
            AuthorCell(authorName: "Jair Bolsonaro", authorImageURL: "", soundCount: "10")
            
            AuthorCell(authorName: "Samira Close", authorImageURL: "https://yt3.ggpht.com/ytc/AKedOLRjdzsZyL8rKC0c83BV7_muqPkBtd2TM1kYrV76iA=s900-c-k-c0x00ffffff-no-rj", soundCount: "1")
            AuthorCell(authorName: "Casimiro", authorImageURL: "https://pbs.twimg.com/profile_images/1495509561377177601/WljXGF65_400x400.jpg", soundCount: "4")
            
            // URL unavailable
            AuthorCell(authorName: "Samira Close", authorImageURL: "abc", soundCount: "1")
        }
        .previewLayout(.fixed(width: 220, height: 100))
    }

}

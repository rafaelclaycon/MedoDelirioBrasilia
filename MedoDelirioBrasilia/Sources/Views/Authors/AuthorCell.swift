//
//  AuthorCell.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 18/07/22.
//

import SwiftUI
import Kingfisher

struct AuthorCell: View {

    let author: Author

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.gray)
                .frame(height: UIDevice.is4InchDevice ? 120 : 96)
                .opacity(colorScheme == .dark ? 0.25 : 0.15)
            
            HStack {
                if author.photo?.isEmpty == false {
                    KFImage(URL(string: author.photo ?? ""))
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
                    Text(author.name)
                        .foregroundColor(.primary)
                        .bold()
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                .padding(.leading, 5)

                Spacer()

                NumberBadgeView(number: "\(author.soundCount ?? 0)", showBackgroundCircle: true)
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

#Preview {
    Group {
        // No image
        AuthorCell(
            author: .init(id: "", name: "Jair Bolsonaro", soundCount: 10)
        )

        AuthorCell(
            author: .init(
                id: "",
                name: "Samira Close",
                photo: "https://yt3.ggpht.com/ytc/AKedOLRjdzsZyL8rKC0c83BV7_muqPkBtd2TM1kYrV76iA=s900-c-k-c0x00ffffff-no-rj",
                soundCount: 1
            )
        )
        AuthorCell(
            author: .init(
                id: "",
                name: "Casimiro",
                photo: "https://pbs.twimg.com/profile_images/1495509561377177601/WljXGF65_400x400.jpg",
                soundCount: 4
            )
        )

        // URL unavailable
        AuthorCell(
            author: .init(id: "", name: "Samira Close", photo: "abc", soundCount: 1)
        )
    }
    .padding()
}

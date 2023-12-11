//
//  AuthorCell.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 10/12/23.
//

import SwiftUI
import Kingfisher

struct AuthorCell: View {

    let author: Author

    @Environment(\.colorScheme) var colorScheme

    var hasBackgroundImage: Bool {
        author.photo?.isEmpty == false
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.gray)
                .frame(height: 96)
                .opacity(colorScheme == .dark ? 0.25 : 0.15)

            if hasBackgroundImage {
                KFImage(URL(string: author.photo ?? ""))
                    .placeholder {
                        EmptyView()
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(height: 96)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .blur(radius: 200, opaque: false)
            }

            HStack {
                if author.photo?.isEmpty == false {
                    KFImage(URL(string: author.photo ?? ""))
                        .placeholder {
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 50)
                                .foregroundColor(.gray)
                                .opacity(0.3)
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(width: 96, height: 96)
                        .clipped()
                }

                VStack(alignment: .leading) {
                    Text(author.name)
                        .foregroundColor(.primary)
                        .bold()
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                .padding(.leading, author.photo?.isEmpty == false ? 15 : 25)

                Spacer()

                NumberBadgeView(
                    number: "\(author.soundCount ?? 0)",
                    showBackgroundCircle: true,
                    lightModeOpacity: hasBackgroundImage ? 0.5 : 0.2,
                    darkModeOpacity: hasBackgroundImage ? 0.25 : 0.5,
                    circleColor: hasBackgroundImage ? .white : .gray
                )
                .foregroundColor(.primary)
            }
            .padding(.trailing, 18)
        }
        .mask {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
        }
    }
}

#Preview {
    Group {
        // No image
        AuthorCell(
            author: .init(id: "", name: "Jair Bolsonaro", soundCount: 10)
        )

        // Square image
        AuthorCell(
            author: .init(
                id: "",
                name: "Samira Close",
                photo: "https://yt3.ggpht.com/ytc/AKedOLRjdzsZyL8rKC0c83BV7_muqPkBtd2TM1kYrV76iA=s900-c-k-c0x00ffffff-no-rj",
                soundCount: 1
            )
        )

        // Image is taller than wider
        AuthorCell(
            author: .init(
                id: "",
                name: "Abraham Weintraub",
                photo: "https://conteudo.imguol.com.br/c/noticias/fd/2020/06/22/11fev2020---o-entao-ministro-da-educacao-abraham-weintraub-falando-a-comissao-do-senado-sobre-problemas-na-correcao-das-provas-do-enem-1592860563916_v2_3x4.jpg",
                soundCount: 5
            )
        )

        // Image is wider than taller
        AuthorCell(
            author: .init(
                id: "",
                name: "Biquini",
                photo: "https://conteudo.imguol.com.br/c/entretenimento/10/2019/05/30/integrantes-do-biquini-cavadao-1559247575758_v2_4x3.jpg",
                soundCount: 5
            )
        )

        // URL unavailable
        AuthorCell(
            author: .init(id: "", name: "Samira Close", photo: "abc", soundCount: 1)
        )
    }
    .padding()
}

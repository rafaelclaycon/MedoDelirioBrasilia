//
//  VerticalAuthorView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 01/05/25.
//

import SwiftUI
import Kingfisher

struct VerticalAuthorView: View {
    
    let author: Author

    @Environment(\.colorScheme) var colorScheme

    private var hasBackgroundImage: Bool {
        author.photo?.isEmpty == false
    }

    @ScaledMetric private var imageHeight: CGFloat = 96
    @ScaledMetric private var placeholderHeight: CGFloat = 70

    var body: some View {
        VStack(spacing: .zero) {
            KFImage(URL(string: author.photo ?? ""))
                .placeholder {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: placeholderHeight)
                        .foregroundColor(.gray)
                        .opacity(0.3)
                }
                .resizable()
                .scaledToFill()
                .frame(height: imageHeight)
                .clipped()

            VStack(alignment: .leading) {
                Text(author.name)
                    .foregroundColor(.primary)
                    .bold()
                    .lineLimit(1)
            }
            .padding(.vertical, .spacing(.small))
            .padding(.horizontal, .spacing(.medium))
        }
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.gray)
                .opacity(colorScheme == .dark ? 0.25 : 0.15)

            if hasBackgroundImage {
                KFImage(URL(string: author.photo ?? ""))
                    .placeholder {
                        EmptyView()
                    }
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 200, opaque: false)
            }
        }
        .mask {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
        }
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Previews

#Preview {
    ScrollView {
        VStack {
            // No image
            VerticalAuthorView(
                author: .init(id: "", name: "Jair Bolsonaro", soundCount: 10)
            )

            // Square image
            VerticalAuthorView(
                author: .init(
                    id: "",
                    name: "Samira Close",
                    photo: "https://yt3.ggpht.com/ytc/AKedOLRjdzsZyL8rKC0c83BV7_muqPkBtd2TM1kYrV76iA=s900-c-k-c0x00ffffff-no-rj",
                    soundCount: 1
                )
            )

            // Image is taller than wider
            VerticalAuthorView(
                author: .init(
                    id: "",
                    name: "Abraham Weintraub",
                    photo: "https://conteudo.imguol.com.br/c/noticias/fd/2020/06/22/11fev2020---o-entao-ministro-da-educacao-abraham-weintraub-falando-a-comissao-do-senado-sobre-problemas-na-correcao-das-provas-do-enem-1592860563916_v2_3x4.jpg",
                    soundCount: 5
                )
            )

            // Image is wider than taller
            VerticalAuthorView(
                author: .init(
                    id: "",
                    name: "Biquini",
                    photo: "https://conteudo.imguol.com.br/c/entretenimento/10/2019/05/30/integrantes-do-biquini-cavadao-1559247575758_v2_4x3.jpg",
                    soundCount: 5
                )
            )

            // URL unavailable
            VerticalAuthorView(
                author: .init(id: "", name: "Samira Close", photo: "abc", soundCount: 1)
            )
        }
        .padding(.vertical)
        .padding(.horizontal, 115)
    }
}

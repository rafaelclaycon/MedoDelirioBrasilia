//
//  ReactionsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 13/06/22.
//

import SwiftUI

struct ReactionsView: View {

    @StateObject private var viewModel = CollectionsViewViewModel()
    
    private let rows = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                VStack(alignment: .center) {
//                    VStack(spacing: 10) {
//                        Text("*Tá vindo!*")
//                            .foregroundColor(.gray)
//                            .font(.title3)
//                            .multilineTextAlignment(.center)
//                    }
//                    .padding(.vertical, UIDevice.current.userInterfaceIdiom == .phone ? 100 : 200)
//                    
//                    if UIDevice.current.userInterfaceIdiom == .phone {
//                        VStack(spacing: 10) {
//                            Text("Procurando pelas pastas? Agora elas estão na aba Sons.")
//                                .foregroundColor(.gray)
//                                .font(.body)
//                                .multilineTextAlignment(.center)
//                        }
//                        .padding(.vertical, 100)
//                        .padding(.horizontal)
//                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: rows, spacing: 14) {
                            ForEach(viewModel.collections) { reaction in
                                NavigationLink {
                                    ReactionDetailView(
                                        viewModel: .init(reaction: reaction)
                                    )
                                } label: {
                                    ReactionCell(title: reaction.title, imageURL: reaction.imageURL)
                                }
                            }
                        }
                        .frame(height: 210)
                        .padding(.leading)
                        .padding(.trailing)
                    }
                }
                .padding(.top, 10)
            }
            .navigationTitle("Reações")
            .onAppear {
                viewModel.reloadCollectionList(withCollections: getLocalCollections())
            }
            .padding(.bottom)
        }
    }
    
    private func getLocalCollections() -> [Reaction] {
        var array = [Reaction]()
        array.append(Reaction(title: "lgbt+", imageURL: "http://blog.saude.mg.gov.br/wp-content/uploads/2021/06/28-06-lgbt.jpg"))
        array.append(Reaction(title: "clássicos", imageURL: "https://www.avina.net/wp-content/uploads/2019/06/Confiamos-no-Brasil-e-nos-brasileiros-e-brasileiras.jpg"))
        array.append(Reaction(title: "sérios", imageURL: "https://images.trustinnews.pt/uploads/sites/5/2019/10/tres-tabus-que-o-homem-atual-ja-ultrapassou-2.jpeg"))
        array.append(Reaction(title: "sarcásticos", imageURL: "https://i.scdn.co/image/0a32a3b9a4f798833f1c10aac18197f7b119e758"))
        array.append(Reaction(title: "esperança", imageURL: "https://i.ytimg.com/vi/r0jh29F6hSs/mqdefault.jpg"))
        return array
    }

}

struct CollectionsView_Previews: PreviewProvider {

    static var previews: some View {
        ReactionsView()
    }

}

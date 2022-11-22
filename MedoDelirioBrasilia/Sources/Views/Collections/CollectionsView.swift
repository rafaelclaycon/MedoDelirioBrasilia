//
//  CollectionsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 13/06/22.
//

import SwiftUI

struct CollectionsView: View {

    @StateObject private var viewModel = CollectionsViewViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                VStack(alignment: .center) {
                    CollectionListView(viewModel: CollectionListViewViewModel(state: .loading))
                        .padding(.top, 10)
                    
                    VStack(spacing: 10) {
                        Text("*Tá vindo!*")
                            .foregroundColor(.gray)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, UIDevice.current.userInterfaceIdiom == .phone ? 100 : 200)
                    
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        VStack(spacing: 10) {
                            Text("Procurando pelas pastas? Agora elas estão na aba Sons.")
                                .foregroundColor(.gray)
                                .font(.body)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 100)
                        .padding(.horizontal)
                    }
                    
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            LazyHGrid(rows: rows, spacing: 14) {
//                                ForEach(viewModel.collections) { collection in
//                                    NavigationLink {
//                                        CollectionDetailView()
//                                    } label: {
//                                        CollectionCell(title: collection.title, imageURL: collection.imageURL)
//                                    }
//                                }
//                            }
//                            .frame(height: 210)
//                            .padding(.leading)
//                            .padding(.trailing)
//                        }
                }
                .padding(.top, 10)
            }
            .navigationTitle("Coleções")
            .onAppear {
                //viewModel.donateActivity()
            }
            .padding(.bottom)
        }
    }

}

struct CollectionsView_Previews: PreviewProvider {

    static var previews: some View {
        CollectionsView()
    }

}

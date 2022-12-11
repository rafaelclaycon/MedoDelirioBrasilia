//
//  CollectionsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 13/06/22.
//

import SwiftUI

struct CollectionsView: View {

    //@StateObject private var viewModel = CollectionsViewViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                VStack(alignment: .center) {
                    CollectionListView(viewModel: CollectionListViewViewModel(state: .loading))
                        .padding(.top, 10)
                    
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
            .navigationTitle("Reações")
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

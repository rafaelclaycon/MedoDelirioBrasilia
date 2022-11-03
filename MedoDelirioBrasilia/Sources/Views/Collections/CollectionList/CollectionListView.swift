//
//  CollectionListView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/10/22.
//

import SwiftUI

struct CollectionListView: View {

    @StateObject var viewModel: CollectionListViewViewModel
    
    private let rows = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Text("Escolhas do Editor")
                    .font(.title2)
                    .padding(.leading)
                
                Spacer()
            }
            
            switch viewModel.state {
            case .loading:
                loadingView()
            case .displayingData:
                listView()
            case .noDataToDisplay:
                noDataView()
            case .loadingError:
                loadingErrorView()
            }
        }
    }
    
    @ViewBuilder private func loadingView() -> some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.3, anchor: .center)
            
            Text("CARREGANDO")
                .foregroundColor(.gray)
                .font(.callout)
        }
        .padding(.vertical, 100)
    }
    
    @ViewBuilder private func listView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows, spacing: 14) {
                ForEach(viewModel.collections) { collection in
                    NavigationLink {
                        CollectionDetailView(collection: collection)
                    } label: {
                        CollectionCell(title: collection.title, imageURL: collection.imageURL)
                    }
                }
            }
            .frame(height: 250)
            .padding(.leading)
            .padding(.trailing)
        }
    }
    
    @ViewBuilder private func noDataView() -> some View {
        VStack(spacing: 10) {
            Text("Nenhuma Coleção")
                .foregroundColor(.gray)
                .font(.title3)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, UIDevice.current.userInterfaceIdiom == .phone ? 100 : 200)
    }
    
    @ViewBuilder private func loadingErrorView() -> some View {
        VStack(spacing: 10) {
            Text("Erro ao Tentar Carregar Coleções")
                .foregroundColor(.gray)
                .font(.title3)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, UIDevice.current.userInterfaceIdiom == .phone ? 100 : 200)
    }

}

struct CollectionListView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            CollectionListView(viewModel: CollectionListViewViewModel(state: .loading))
            CollectionListView(viewModel: CollectionListViewViewModel(state: .displayingData))
            CollectionListView(viewModel: CollectionListViewViewModel(state: .noDataToDisplay))
            CollectionListView(viewModel: CollectionListViewViewModel(state: .loadingError))
        }
    }

}
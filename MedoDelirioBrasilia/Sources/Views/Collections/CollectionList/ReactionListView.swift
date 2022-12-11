//
//  ReactionListView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/10/22.
//

import SwiftUI

struct ReactionListView: View {

    @StateObject var viewModel: ReactionListViewViewModel
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .center) {
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
        .onAppear {
            viewModel.fetchCollections()
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
        ScrollView {
            LazyVGrid(columns: columns, spacing: UIDevice.current.userInterfaceIdiom == .phone ? 14 : 20) {
                ForEach(viewModel.collections) { collection in
                    NavigationLink {
                        ReactionDetailView(collection: collection)
                    } label: {
                        ReactionCell(title: collection.title, imageURL: collection.imageURL)
                    }
                }
            }
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
            ReactionListView(viewModel: ReactionListViewViewModel(state: .loading))
            ReactionListView(viewModel: ReactionListViewViewModel(state: .displayingData))
            ReactionListView(viewModel: ReactionListViewViewModel(state: .noDataToDisplay))
            ReactionListView(viewModel: ReactionListViewViewModel(state: .loadingError))
        }
    }

}

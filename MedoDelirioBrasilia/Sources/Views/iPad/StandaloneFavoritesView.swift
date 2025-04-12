//
//  StandaloneFavoritesView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 12/04/25.
//

import SwiftUI

struct StandaloneFavoritesView: View {

    @StateObject var viewModel: StandaloneFavoritesViewModel
    @StateObject private var favoritesViewModel: ContentListViewModel<[AnyEquatableMedoContent]>

    @State private var soundSearchTextIsEmpty: Bool? = true

    // MARK: - Initializer

    init(
        viewModel: StandaloneFavoritesViewModel
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._favoritesViewModel = StateObject(wrappedValue: ContentListViewModel<[AnyEquatableMedoContent]>(
            data: viewModel.dataPublisher,
            menuOptions: [.sharingOptions(), .organizingOptions(), .detailsOptions()],
            currentSoundsListMode: .constant(.regular)
        ))
    }

    // MARK: - View Body

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: .spacing(.xSmall)) {
                    ContentList<EmptyView, VStack, VStack, VStack>(
                        viewModel: favoritesViewModel,
                        soundSearchTextIsEmpty: $soundSearchTextIsEmpty,
                        dataLoadingDidFail: viewModel.dataLoadingDidFail,
                        containerSize: geometry.size,
                        loadingView:
                            VStack {
                                HStack(spacing: 10) {
                                    ProgressView()

                                    Text("Carregando sons...")
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        ,
                        emptyStateView:
                            VStack {
                                NoFavoritesView()
                                    .padding(.horizontal, .spacing(.xLarge))
                                    .padding(.vertical, .spacing(.huge))
                            }
                        ,
                        errorView:
                            VStack {
                                HStack(spacing: 10) {
                                    ProgressView()

                                    Text("Erro ao carregar sons.")
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                            }
                    )
                }
                .navigationTitle(Text("Favoritos"))
                //            .navigationBarItems(
                //                leading: LeadingToolbarControls(
                //                    isSelecting: currentSoundsListMode.wrappedValue == .selection,
                //                    cancelAction: { allSoundsViewModel.onExitMultiSelectModeSelected() },
                //                    openSettingsAction: openSettingsAction
                //                ),
                //                trailing: trailingToolbarControls()
                //            )
                .onAppear {
                    viewModel.onViewDidAppear()
                }
            }
        }
    }
}


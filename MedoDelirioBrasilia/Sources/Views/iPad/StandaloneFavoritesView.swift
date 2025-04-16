//
//  StandaloneFavoritesView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 12/04/25.
//

import SwiftUI

struct StandaloneFavoritesView: View {

    @State var viewModel: StandaloneFavoritesViewModel
    @State private var favoritesViewModel: ContentGridViewModel

    @State private var soundSearchTextIsEmpty: Bool? = true

    // MARK: - Initializer

    init(
        viewModel: StandaloneFavoritesViewModel,
        toast: Binding<Toast?>,
        contentRepository: ContentRepositoryProtocol
    ) {
        self.viewModel = viewModel
        self.favoritesViewModel = ContentGridViewModel(
            contentRepository: contentRepository,
            userFolderRepository: UserFolderRepository(database: LocalDatabase.shared),
            screen: .standaloneFavoritesView,
            menuOptions: [.sharingOptions(), .organizingOptions(), .detailsOptions()],
            currentListMode: .constant(.regular),
            toast: toast,
            floatingOptions: .constant(nil),
            analyticsService: AnalyticsService()
        )
    }

    // MARK: - View Body

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: .spacing(.xSmall)) {
//                    ContentGrid(
//                        viewModel: favoritesViewModel,
//                        searchTextIsEmpty: $soundSearchTextIsEmpty,
//                        dataLoadingDidFail: viewModel.dataLoadingDidFail,
//                        containerSize: geometry.size,
//                        loadingView:
//                            VStack {
//                                HStack(spacing: 10) {
//                                    ProgressView()
//
//                                    Text("Carregando sons...")
//                                        .foregroundColor(.gray)
//                                }
//                                .frame(maxWidth: .infinity)
//                            }
//                        ,
//                        emptyStateView:
//                            VStack {
//                                NoFavoritesView()
//                                    .padding(.horizontal, .spacing(.xLarge))
//                                    .padding(.vertical, .spacing(.huge))
//                            }
//                        ,
//                        errorView:
//                            VStack {
//                                HStack(spacing: 10) {
//                                    ProgressView()
//
//                                    Text("Erro ao carregar sons.")
//                                        .foregroundColor(.gray)
//                                }
//                                .frame(maxWidth: .infinity)
//                            }
//                    )

                    Spacer()
                        .frame(height: .spacing(.large))
                }
                .padding(.horizontal, .spacing(.medium))
                .navigationTitle(Text("Favoritos"))
                //            .navigationBarItems(
                //                leading: LeadingToolbarControls(
                //                    isSelecting: currentContentListMode.wrappedValue == .selection,
                //                    cancelAction: { allSoundsViewModel.onExitMultiSelectModeSelected() },
                //                    openSettingsAction: openSettingsAction
                //                ),
                //                trailing: trailingToolbarControls()
                //            )
                .onAppear {
                    viewModel.onViewDidAppear()
                }
            }
            .toast(favoritesViewModel.toast)
            .floatingContentOptions(favoritesViewModel.floatingOptions)
        }
    }
}


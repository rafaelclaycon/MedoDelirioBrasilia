//
//  StandaloneFavoritesView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 12/04/25.
//

import SwiftUI

struct StandaloneFavoritesView: View {

    @StateObject var viewModel: StandaloneFavoritesViewModel
    @StateObject private var favoritesViewModel: ContentGridViewModel<[AnyEquatableMedoContent]>

    @State private var soundSearchTextIsEmpty: Bool? = true

    private var toast: Binding<Toast?>

    // MARK: - Initializer

    init(
        viewModel: StandaloneFavoritesViewModel,
        toast: Binding<Toast?>
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._favoritesViewModel = StateObject(wrappedValue: ContentGridViewModel<[AnyEquatableMedoContent]>(
            data: viewModel.dataPublisher,
            menuOptions: [.sharingOptions(), .organizingOptions(), .detailsOptions()],
            currentListMode: .constant(.regular),
            toast: toast
        ))
        self.toast = toast
    }

    // MARK: - View Body

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: .spacing(.xSmall)) {
                    ContentGrid<EmptyView, VStack, VStack, VStack>(
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
            .toast(toast)
        }
    }
}


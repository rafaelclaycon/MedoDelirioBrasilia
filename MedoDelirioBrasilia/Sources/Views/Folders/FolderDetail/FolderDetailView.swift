//
//  FolderDetailView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI

struct FolderDetailView: View {

    @State private var viewModel: FolderDetailViewModel
    @State private var contentGridViewModel: ContentGridViewModel

    let folder: UserFolder

    private var currentContentListMode: Binding<ContentGridMode>
    @State private var showingFolderInfoEditingView = false
    @State private var showingModalView = false

    // MARK: - Computed Properties

    private var showSortByDateAddedOption: Bool {
        guard let folderVersion = folder.version else { return false }
        return folderVersion == "2"
    }
    
    private var title: String {
        guard currentContentListMode.wrappedValue == .regular else {
            if contentGridViewModel.selectionKeeper.count == 0 {
                return Shared.SoundSelection.selectSounds
            } else if contentGridViewModel.selectionKeeper.count == 1 {
                return Shared.SoundSelection.soundSelectedSingular
            } else {
                return String(format: Shared.SoundSelection.soundsSelectedPlural, contentGridViewModel.selectionKeeper.count)
            }
        }
        return "\(folder.symbol)  \(folder.name)"
    }

    private var loadedContent: [AnyEquatableMedoContent] {
        guard case .loaded(let content) = viewModel.state else { return [] }
        return content
    }

    // MARK: - Initializer

    init(
        viewModel: FolderDetailViewModel,
        folder: UserFolder,
        currentContentListMode: Binding<ContentGridMode>,
        toast: Binding<Toast?>,
        floatingOptions: Binding<FloatingContentOptions?>,
        contentRepository: ContentRepositoryProtocol
    ) {
        self.folder = folder

        self.viewModel = viewModel
        self.currentContentListMode = currentContentListMode

        self.contentGridViewModel = ContentGridViewModel(
            contentRepository: contentRepository,
            userFolderRepository: UserFolderRepository(database: LocalDatabase.shared),
            screen: .folderDetailView,
            menuOptions: [.sharingOptions(), .playFromThisSound(), .removeFromFolder()],
            currentListMode: currentContentListMode,
            toast: toast,
            floatingOptions: floatingOptions,
            refreshAction: { viewModel.onContentWasRemovedFromFolder() },
            insideFolder: folder,
            multiSelectFolderOperation: .remove,
            analyticsService: AnalyticsService()
        )
    }

    // MARK: - View Body

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: .spacing(.medium)) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(viewModel.contentCountText)
                                .font(.callout)
                                .foregroundColor(.gray)
                                .bold()

                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top)

                    ContentGrid(
                        state: viewModel.state,
                        viewModel: contentGridViewModel,
                        showNewTag: false,
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
                                EmptyFolderView()
                                    .padding(.horizontal, .spacing(.xxLarge))
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
                    .environment(TrendsHelper())
                    .padding(.horizontal, .spacing(.medium))

                    Spacer()
                        .frame(height: .spacing(.large))
                }
                .navigationTitle(title)
                .toolbar { trailingToolbarControls() }
                .onAppear {
                    viewModel.onViewAppeared()
                }
                .onDisappear {
                    contentGridViewModel.onViewDisappeared()
                }
                .sheet(isPresented: $showingFolderInfoEditingView) {
                    FolderInfoEditingView(
                        folder: folder,
                        folderRepository: UserFolderRepository(database: LocalDatabase.shared),
                        dismissSheet: {
                            showingFolderInfoEditingView = false
                        }
                    )
                }
            }
            .toast(contentGridViewModel.toast)
            .floatingContentOptions(contentGridViewModel.floatingOptions)
        }
    }

    // MARK: - Subviews

    @ViewBuilder func trailingToolbarControls() -> some View {
        HStack(spacing: 16) {
            if currentContentListMode.wrappedValue == .regular {
                Button {
                    contentGridViewModel.onPlayStopPlaylistSelected(loadedContent: loadedContent)
                } label: {
                    Image(systemName: contentGridViewModel.isPlayingPlaylist ? "stop.fill" : "play.fill")
                }
                .disabled(viewModel.contentCount == 0)
            } else {
                selectionControls()
            }

            Menu {
                Section {
                    Button {
                        contentGridViewModel.onEnterMultiSelectModeSelected(
                            loadedContent: loadedContent,
                            isFavoritesOnlyView: false
                        )
                    } label: {
                        Label(
                            currentContentListMode.wrappedValue == .selection ? "Cancelar Seleção" : "Selecionar",
                            systemImage: currentContentListMode.wrappedValue == .selection ? "xmark.circle" : "checkmark.circle"
                        )
                    }
                }

                Section {
                    Picker("Ordenação de Sons", selection: $viewModel.contentSortOption) {
                        Text("Título")
                            .tag(0)

                        Text("Nome do(a) Autor(a)")
                            .tag(1)

                        if showSortByDateAddedOption {
                            Text("Adição à Pasta (Mais Recentes no Topo)")
                                .tag(2)
                        }
                    }
                    .onChange(of: viewModel.contentSortOption) {
                        contentGridViewModel.onContentSortingChanged()
                        viewModel.onContentSortOptionChanged()
                    }
                    .disabled(viewModel.contentCount == 0)
                }

                //                    Section {
                //                        Button {
                //                            showingFolderInfoEditingView = true
                //                        } label: {
                //                            Label("Exportar", systemImage: "square.and.arrow.up")
                //                        }
                //
                //                        Button {
                //                            showingFolderInfoEditingView = true
                //                        } label: {
                //                            Label("Importar", systemImage: "square.and.arrow.down")
                //                        }
                //                    }

                //                    Section {
                //                        Button {
                //                            showingFolderInfoEditingView = true
                //                        } label: {
                //                            Label("Editar Pasta", systemImage: "pencil")
                //                        }
                //
                //                        Button(role: .destructive, action: {
                //                            //viewModel.dummyCall()
                //                        }, label: {
                //                            HStack {
                //                                Text("Apagar Pasta")
                //                                Image(systemName: "trash")
                //                            }
                //                        })
                //                    }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .disabled(contentGridViewModel.isPlayingPlaylist || (viewModel.contentCount == 0))
        }
    }
    
    @ViewBuilder func selectionControls() -> some View {
        if currentContentListMode.wrappedValue == .regular {
            EmptyView()
        } else {
            HStack(spacing: 16) {
                Button {
                    currentContentListMode.wrappedValue = .regular
                    contentGridViewModel.selectionKeeper.removeAll()
                } label: {
                    Text("Cancelar")
                        .bold()
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let folder = UserFolder(
        symbol: "🤑",
        name: "Grupo da Economia",
        backgroundColor: "pastelBabyBlue",
        changeHash: "abcdefg"
    )

    return FolderDetailView(
        viewModel: FolderDetailViewModel(
            folder: folder,
            contentRepository: FakeContentRepository()
        ),
        folder: folder,
        currentContentListMode: .constant(.regular),
        toast: .constant(nil),
        floatingOptions: .constant(nil),
        contentRepository: FakeContentRepository()
    )
}

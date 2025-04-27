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
                    HeaderView(
                        title: title,
                        color: folder.backgroundColor.toColor(),
                        itemCountText: viewModel.contentCountText
                    )
                    //.border(.red)

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
            .edgesIgnoringSafeArea(.top)
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

// MARK: - Subviews

extension FolderDetailView {

    struct StickyFolderBackgroundView: View {

        let color: Color
        let height: CGFloat

        // MARK: - Computed Properties

        private func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
            geometry.frame(in: .global).minY
        }

        private func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
            let offset = getScrollOffset(geometry)
            // Image was pulled down
            if offset > 0 {
                return -offset
            }
            return 0
        }

        private func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
            let offset = getScrollOffset(geometry)
            let imageHeight = geometry.size.height
            if offset > 0 {
                return imageHeight + offset
            }
            return imageHeight
        }

        // MARK: - View Body

        var body: some View {
            //GeometryReader { headerPhotoGeometry in
                Rectangle()
                .fill("pastelPurple".toPastelColor())
                    .frame(height: height)
                    .overlay { FolderView.SpeckleOverlay() }
//                    .frame(
//                        width: headerPhotoGeometry.size.width,
//                        height: self.getHeightForHeaderImage(headerPhotoGeometry)
//                    )
//                    .offset(x: 0, y: self.getOffsetForHeaderImage(headerPhotoGeometry))
//            }
//            .frame(height: height)
        }
    }

    struct HeaderView: View {

        let title: String
        let color: Color
        let itemCountText: String

        var body: some View {
            VStack(alignment: .leading, spacing: .spacing(.medium)) {
                StickyFolderBackgroundView(color: color, height: 200)
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading) {
                            Text(title)
                                .font(.largeTitle)
                                .bold()
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
//                                .foregroundStyle(.white)
//                                .shadow(color: .black, radius: 3, x: 1.5, y: 1.5)
                        }
                        .padding(.all, .spacing(.large))
                    }

                Text(itemCountText)
                    .font(.callout)
                    .foregroundColor(.gray)
                    .bold()
                    .padding(.leading, .spacing(.medium))
                    //.padding(.bottom, .spacing(.small))
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
        changeHash: "abcdefg",
        contentCount: 3
    )
    var repo = FakeContentRepository()
    let sounds: [Sound] = Sound.sampleSounds
    repo.content = sounds.map { AnyEquatableMedoContent($0) }

    return NavigationStack {
        FolderDetailView(
            viewModel: FolderDetailViewModel(
                folder: folder,
                contentRepository: repo
            ),
            folder: folder,
            currentContentListMode: .constant(.regular),
            toast: .constant(nil),
            floatingOptions: .constant(nil),
            contentRepository: repo
        )
    }
}

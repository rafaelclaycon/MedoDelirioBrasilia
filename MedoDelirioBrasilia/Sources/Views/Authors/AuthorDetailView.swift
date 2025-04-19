//
//  AuthorDetailView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/05/22.
//

import SwiftUI

struct AuthorDetailView: View {

    @State private var viewModel: AuthorDetailViewModel
    @State private var contentGridViewModel: ContentGridViewModel

    let author: Author

    @State private var navBarTitle: String = ""
    private var currentContentListMode: Binding<ContentListMode>

    @State private var showingModalView = false

    // MARK: - Computed Properties

    private var title: String {
        guard currentContentListMode.wrappedValue == .regular else {
            if contentGridViewModel.selectionKeeper.count == 0 {
                return Shared.SoundSelection.selectSounds
            } else if contentGridViewModel.selectionKeeper.count == 1 {
                return Shared.SoundSelection.soundSelectedSingular
            } else {
                return String(
                    format: Shared.SoundSelection.soundsSelectedPlural,
                    contentGridViewModel.selectionKeeper.count
                )
            }
        }
        return author.name
    }

    private var edgesToIgnore: SwiftUI.Edge.Set {
        return author.photo == nil ? [] : .top
    }

    private func getOffsetBeforeShowingTitle() -> CGFloat {
        author.photo == nil ? 50 : 250
    }

    private func updateNavBarContent(_ offset: CGFloat) {
        if offset < getOffsetBeforeShowingTitle() {
            DispatchQueue.main.async {
                navBarTitle = title
            }
        } else {
            DispatchQueue.main.async {
                navBarTitle = ""
            }
        }
    }

    private var loadedContent: [AnyEquatableMedoContent] {
        guard case .loaded(let content) = viewModel.state else { return [] }
        return content
    }

    // MARK: - Initializer

    init(
        author: Author,
        currentListMode: Binding<ContentListMode>,
        toast: Binding<Toast?>,
        contentRepository: ContentRepositoryProtocol
    ) {
        self.author = author

        self.viewModel = AuthorDetailViewModel(
            authorId: author.id,
            currentContentListMode: currentListMode,
            contentRepository: contentRepository
        )
        self.currentContentListMode = currentListMode

        self.contentGridViewModel = ContentGridViewModel(
            contentRepository: contentRepository,
            userFolderRepository: UserFolderRepository(database: LocalDatabase.shared),
            screen: .authorDetailView,
            menuOptions: [.sharingOptions(), .organizingOptions(), .playFromThisSound(), .authorOptions()],
            currentListMode: currentListMode,
            toast: toast,
            floatingOptions: .constant(nil),
            analyticsService: AnalyticsService()
        )
    }

    // MARK: - View Body

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: .spacing(.medium)) {
                    AuthorHeaderView(
                        author: author,
                        title: title,
                        soundCountText: viewModel.soundCountText
                    )

                    ContentGrid(
                        state: viewModel.state,
                        viewModel: contentGridViewModel,
                        authorId: author.id,
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
                                NoSoundsView()
                                    .padding(.horizontal, 25)
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
                .onPreferenceChange(ViewOffsetKey.self) { offset in
                    updateNavBarContent(offset)
                }
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    viewModel.onViewLoaded()
                }
                .onDisappear {
                    contentGridViewModel.onViewDisappeared()
                }
                .alert(isPresented: $viewModel.showAlert) {
                    switch viewModel.alertType {
                    case .ok:
                        return Alert(
                            title: Text(viewModel.alertTitle),
                            message: Text(viewModel.alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    case .reportSoundIssue:
                        return Alert(
                            title: Text(viewModel.alertTitle),
                            message: Text(viewModel.alertMessage),
                            primaryButton: .default(Text("Relatar Problema por E-mail"), action: { viewModel.showEmailAppPicker_soundUnavailableConfirmationDialog = true }),
                            secondaryButton: .cancel(Text("Fechar"))
                        )
                    case .askForNewSound:
                        return Alert(
                            title: Text(viewModel.alertTitle),
                            message: Text(viewModel.alertMessage),
                            primaryButton: .default(Text("Li e Entendi"), action: { viewModel.showEmailAppPicker_askForNewSound = true }),
                            secondaryButton: .cancel(Text("Cancelar"))
                        )
                    }
                }
                .sheet(isPresented: $viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog) {
                    EmailAppPickerView(
                        isBeingShown: $viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog,
                        toast: contentGridViewModel.toast,
                        subject: String(format: Shared.suggestOtherAuthorNameEmailSubject, viewModel.selectedSound?.title ?? ""),
                        emailBody: String(format: Shared.suggestOtherAuthorNameEmailBody, viewModel.selectedSound?.authorName ?? "", viewModel.selectedSound?.id ?? "")
                    )
                }
                .sheet(isPresented: $viewModel.showEmailAppPicker_askForNewSound) {
                    EmailAppPickerView(
                        isBeingShown: $viewModel.showEmailAppPicker_askForNewSound,
                        toast: contentGridViewModel.toast,
                        subject: String(format: Shared.Email.AskForNewSound.subject, self.author.name),
                        emailBody: Shared.Email.AskForNewSound.body
                    )
                }
                .sheet(isPresented: $viewModel.showEmailAppPicker_reportAuthorDetailIssue) {
                    EmailAppPickerView(
                        isBeingShown: $viewModel.showEmailAppPicker_reportAuthorDetailIssue,
                        toast: contentGridViewModel.toast,
                        subject: String(format: Shared.Email.AuthorDetailIssue.subject, self.author.name),
                        emailBody: Shared.Email.AuthorDetailIssue.body
                    )
                }
                .onChange(of: contentGridViewModel.selectionKeeper.count) {
                    if navBarTitle.isEmpty == false {
                        DispatchQueue.main.async {
                            navBarTitle = title
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(edgesToIgnore)
            .toast(contentGridViewModel.toast)
            .floatingContentOptions(contentGridViewModel.floatingOptions)
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func moreOptionsMenu(isOnToolbar: Bool) -> some View {
        Menu {
            if viewModel.soundCount > 1 {
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
            }
            
            Section {
//                Button {
//                    contentListViewModel.onExitMultiSelectModeSelected()
//                    viewModel.selectedSounds = viewModel.sounds
//                    // showingAddToFolderModal = true // TODO: Fix - move to ContentList
//                } label: {
//                    Label("Adicionar Todos a Pasta", systemImage: "folder.badge.plus")
//                }
                
                Button {
                    contentGridViewModel.onExitMultiSelectModeSelected()
                    viewModel.showAskForNewSoundAlert()
                } label: {
                    Label("Pedir Som Desse Autor", systemImage: "plus.circle")
                }
                
                Button {
                    contentGridViewModel.onExitMultiSelectModeSelected()
                    viewModel.showEmailAppPicker_reportAuthorDetailIssue = true
                } label: {
                    Label("Relatar Problema com os Detalhes Desse Autor", systemImage: "person.crop.circle.badge.exclamationmark")
                }
            }
            
            if viewModel.soundCount > 1 {
                Section {
                    Picker("Ordenação de Sons", selection: $viewModel.soundSortOption) {
                        Text("Título")
                            .tag(0)
                        
                        Text("Mais Recentes no Topo")
                            .tag(1)
                    }
                    .onChange(of: viewModel.soundSortOption) {
                        contentGridViewModel.onContentSortingChanged()
                        viewModel.onSortOptionChanged()
                    }
                }
            }
        } label: {
            if isOnToolbar {
                Image(systemName: "ellipsis.circle")
            } else {
                Image(systemName: "ellipsis.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 26)
            }
        }
        .disabled(viewModel.soundCount == 0)
    }
}

struct ViewOffsetKey: PreferenceKey {

    typealias Value = CGFloat

    static var defaultValue = CGFloat.zero

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

// MARK: - Preview

#Preview {
    AuthorDetailView(
        author: .init(
            id: "0D944922-7E50-4DED-A8FD-F44EFCAE82A2",
            name: "Abraham Weintraub",
            photo: "https://conteudo.imguol.com.br/c/noticias/fd/2020/06/22/11fev2020---o-entao-ministro-da-educacao-abraham-weintraub-falando-a-comissao-do-senado-sobre-problemas-na-correcao-das-provas-do-enem-1592860563916_v2_3x4.jpg",
            description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam."
        ),
        currentListMode: .constant(.regular),
        toast: .constant(nil),
        contentRepository: FakeContentRepository()
    )
}

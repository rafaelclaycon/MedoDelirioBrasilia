//
//  AuthorDetailView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/05/22.
//

import SwiftUI
import Kingfisher

struct AuthorDetailView: View {

    @StateObject private var viewModel: AuthorDetailViewModel
    @StateObject private var contentListViewModel: ContentGridViewModel<[AnyEquatableMedoContent]>

    let author: Author

    @State private var navBarTitle: String = .empty
    private var currentContentListMode: Binding<ContentListMode>
    private var toast: Binding<Toast?>

    @State private var showSelectionControlsInToolbar = false
    @State private var showMenuOnToolbarForiOS16AndHigher = false
    
    @State private var showingModalView = false

    // MARK: - Sticky Header Vars

    private var edgesToIgnore: SwiftUI.Edge.Set {
        return author.photo == nil ? [] : .top
    }

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
    
    private func getOffsetBeforeShowingTitle() -> CGFloat {
        author.photo == nil ? 50 : 250
    }
    
    private func updateNavBarContent(_ offset: CGFloat) {
        if offset < getOffsetBeforeShowingTitle() {
            DispatchQueue.main.async {
                navBarTitle = title
                showSelectionControlsInToolbar = currentContentListMode.wrappedValue == .selection
                showMenuOnToolbarForiOS16AndHigher = currentContentListMode.wrappedValue == .regular
            }
        } else {
            DispatchQueue.main.async {
                navBarTitle = .empty
                showSelectionControlsInToolbar = false
                showMenuOnToolbarForiOS16AndHigher = false
            }
        }
    }

    // MARK: - Computed Properties

    private var title: String {
        guard currentContentListMode.wrappedValue == .regular else {
            if contentListViewModel.selectionKeeper.count == 0 {
                return Shared.SoundSelection.selectSounds
            } else if contentListViewModel.selectionKeeper.count == 1 {
                return Shared.SoundSelection.soundSelectedSingular
            } else {
                return String(
                    format: Shared.SoundSelection.soundsSelectedPlural,
                    contentListViewModel.selectionKeeper.count
                )
            }
        }
        return author.name
    }

    private var externalLinks: [ExternalLink] {
        guard let links = author.externalLinks else {
            return []
        }
        guard let jsonData = links.data(using: .utf8) else {
            return []
        }
        let decoder = JSONDecoder()
        do {
            let decodedLinks = try decoder.decode([ExternalLink].self, from: jsonData)
            return decodedLinks
        } catch {
            print("Error decoding JSON: \(error)")
            return []
        }
    }

    // MARK: - Initializer

    init(
        author: Author,
        currentListMode: Binding<ContentListMode>,
        toast: Binding<Toast?>
    ) {
        self.author = author
        let viewModel = AuthorDetailViewModel(currentContentListMode: currentListMode)

        self._viewModel = StateObject(wrappedValue: viewModel)
        self.currentContentListMode = currentListMode
        self.toast = toast

        let contentListViewModel = ContentGridViewModel<[AnyEquatableMedoContent]>(
            data: viewModel.soundsPublisher,
            menuOptions: [.sharingOptions(), .organizingOptions(), .playFromThisSound(), .authorOptions()],
            currentListMode: currentListMode,
            toast: toast
        )
        self._contentListViewModel = StateObject(wrappedValue: contentListViewModel)
    }

    // MARK: - View Body

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    ContentGrid(
                        viewModel: contentListViewModel,
                        soundSearchTextIsEmpty: .constant(nil),
                        dataLoadingDidFail: viewModel.dataLoadingDidFail,
                        authorId: author.id,
                        containerSize: geometry.size,
                        headerView: {
                            VStack{
                                if let photo = author.photo {
                                    GeometryReader { headerPhotoGeometry in
                                        KFImage(URL(string: photo))
                                            .placeholder {
                                                Image(systemName: "photo.on.rectangle")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 100)
                                                    .foregroundColor(.gray)
                                                    .opacity(0.3)
                                            }
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: headerPhotoGeometry.size.width, height: self.getHeightForHeaderImage(headerPhotoGeometry))
                                            .clipped()
                                            .offset(x: 0, y: self.getOffsetForHeaderImage(headerPhotoGeometry))
                                    }.frame(height: 250)
                                }

                                VStack(alignment: .leading, spacing: 15) {
                                    HStack {
                                        Text(title)
                                            .font(.title)
                                            .bold()

                                        Spacer()

                                        moreOptionsMenu(isOnToolbar: false)
                                    }

                                    if author.description != nil {
                                        Text(author.description ?? "")
                                    }

                                    if !externalLinks.isEmpty {
                                        ViewThatFits(in: .horizontal) {
                                            HStack(spacing: 10) {
                                                ForEach(externalLinks, id: \.title) {
                                                    ExternalLinkButton(externalLink: $0)
                                                }
                                            }
                                            VStack(alignment: .leading, spacing: 15) {
                                                ForEach(externalLinks, id: \.title) {
                                                    ExternalLinkButton(externalLink: $0)
                                                }
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }

                                    Text(viewModel.soundCount)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .bold()
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 10)
                                .padding(.bottom, 5)
                            }
                        },
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
                }
                .onPreferenceChange(ViewOffsetKey.self) { offset in
                    updateNavBarContent(offset)
                }
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    // TODO: Refactor this to be closer to SoundsView.
                    viewModel.loadSounds(for: author.id)
                }
                .onDisappear {
                    contentListViewModel.onViewDisappeared()
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
                        toast: toast,
                        subject: String(format: Shared.suggestOtherAuthorNameEmailSubject, viewModel.selectedSound?.title ?? ""),
                        emailBody: String(format: Shared.suggestOtherAuthorNameEmailBody, viewModel.selectedSound?.authorName ?? "", viewModel.selectedSound?.id ?? "")
                    )
                }
                .sheet(isPresented: $viewModel.showEmailAppPicker_askForNewSound) {
                    EmailAppPickerView(
                        isBeingShown: $viewModel.showEmailAppPicker_askForNewSound,
                        toast: toast,
                        subject: String(format: Shared.Email.AskForNewSound.subject, self.author.name),
                        emailBody: Shared.Email.AskForNewSound.body
                    )
                }
                .sheet(isPresented: $viewModel.showEmailAppPicker_reportAuthorDetailIssue) {
                    EmailAppPickerView(
                        isBeingShown: $viewModel.showEmailAppPicker_reportAuthorDetailIssue,
                        toast: toast,
                        subject: String(format: Shared.Email.AuthorDetailIssue.subject, self.author.name),
                        emailBody: Shared.Email.AuthorDetailIssue.body
                    )
                }
                .onChange(of: contentListViewModel.selectionKeeper.count) {
                    if navBarTitle.isEmpty == false {
                        DispatchQueue.main.async {
                            navBarTitle = title
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(edgesToIgnore)
            .toast(toast)
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func moreOptionsMenu(isOnToolbar: Bool) -> some View {
        Menu {
            if viewModel.sounds.count > 1 {
                Section {
                    Button {
                        contentListViewModel.onEnterMultiSelectModeSelected()
                    } label: {
                        Label(
                            currentContentListMode.wrappedValue == .selection ? "Cancelar Seleção" : "Selecionar",
                            systemImage: currentContentListMode.wrappedValue == .selection ? "xmark.circle" : "checkmark.circle"
                        )
                    }
                }
            }
            
            Section {
                Button {
                    contentListViewModel.onExitMultiSelectModeSelected()
                    viewModel.selectedSounds = viewModel.sounds
                    // showingAddToFolderModal = true // TODO: Fix - move to ContentList
                } label: {
                    Label("Adicionar Todos a Pasta", systemImage: "folder.badge.plus")
                }
                
                Button {
                    contentListViewModel.onExitMultiSelectModeSelected()
                    viewModel.showAskForNewSoundAlert()
                } label: {
                    Label("Pedir Som Desse Autor", systemImage: "plus.circle")
                }
                
                Button {
                    contentListViewModel.onExitMultiSelectModeSelected()
                    viewModel.showEmailAppPicker_reportAuthorDetailIssue = true
                } label: {
                    Label("Relatar Problema com os Detalhes Desse Autor", systemImage: "person.crop.circle.badge.exclamationmark")
                }
            }
            
            if viewModel.sounds.count > 1 {
                Section {
                    Picker("Ordenação de Sons", selection: $viewModel.soundSortOption) {
                        Text("Título")
                            .tag(0)
                        
                        Text("Mais Recentes no Topo")
                            .tag(1)
                    }
                    .onChange(of: viewModel.soundSortOption) {
                        viewModel.sortSounds(by: viewModel.soundSortOption)
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
        .disabled(viewModel.sounds.count == 0)
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
        toast: .constant(nil)
    )
}

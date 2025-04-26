//
//  AuthorHeaderView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 19/04/25.
//

import SwiftUI
import Kingfisher

struct AuthorHeaderView: View {

    let author: Author
    let title: String
    let soundCount: Int
    let soundCountText: String
    var containerWidth: CGFloat = 400

    let contentListMode: ContentGridMode
    @Binding var contentSortOption: Int
    let multiSelectAction: () -> Void
    let askForSoundAction: () -> Void
    let reportIssueAction: () -> Void
    let contentSortChangeAction: () -> Void

    // MARK: - View Body

    var body: some View {
        if UIDevice.isiPhone {
            PhoneHeader(
                author: author,
                title: title,
                soundCount: soundCount,
                soundCountText: soundCountText,
                contentListMode: contentListMode,
                contentSortOption: $contentSortOption,
                multiSelectAction: multiSelectAction,
                askForSoundAction: askForSoundAction,
                reportIssueAction: reportIssueAction,
                contentSortChangeAction: contentSortChangeAction
            )
        } else {
            PadHeader(
                author: author,
                title: title,
                soundCount: soundCount,
                soundCountText: soundCountText,
                containerWidth: containerWidth,
                contentListMode: contentListMode,
                contentSortOption: $contentSortOption,
                multiSelectAction: multiSelectAction,
                askForSoundAction: askForSoundAction,
                reportIssueAction: reportIssueAction,
                contentSortChangeAction: contentSortChangeAction
            )
        }
    }
}

// MARK: - Subviews

extension AuthorHeaderView {

    struct StickyPhotoView: View {

        let photoUrl: URL
        let height: CGFloat
        var blurAndDarken: Bool = false

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
            GeometryReader { headerPhotoGeometry in
                KFImage(photoUrl)
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
                    .overlay(blurAndDarken ? Color.black.opacity(0.3) : Color.clear)
                    .blur(radius: blurAndDarken ? 5 : 0)
                    .scaleEffect(blurAndDarken ? 1.05 : 1)
                    .frame(
                        width: headerPhotoGeometry.size.width,
                        height: self.getHeightForHeaderImage(headerPhotoGeometry)
                    )
                    .clipped()
                    .offset(x: 0, y: self.getOffsetForHeaderImage(headerPhotoGeometry))
            }
            .frame(height: height)
        }
    }

    struct PhoneHeader: View {

        let author: Author
        let title: String
        let soundCount: Int
        let soundCountText: String

        let contentListMode: ContentGridMode
        @Binding var contentSortOption: Int
        let multiSelectAction: () -> Void
        let askForSoundAction: () -> Void
        let reportIssueAction: () -> Void
        let contentSortChangeAction: () -> Void

        var body: some View {
            VStack {
                if let photo = author.photo, let photoUrl = URL(string: photo) {
                    StickyPhotoView(photoUrl: photoUrl, height: 250)
                }

                VStack(alignment: .leading, spacing: .spacing(.medium)) {
                    HStack {
                        Text(title)
                            .font(.title)
                            .bold()

                        Spacer()

                        MoreOptionsMenu(
                            soundCount: soundCount,
                            contentListMode: contentListMode,
                            contentSortOption: $contentSortOption,
                            multiSelectAction: multiSelectAction,
                            askForSoundAction: askForSoundAction,
                            reportIssueAction: reportIssueAction,
                            contentSortChangeAction: contentSortChangeAction
                        )
                    }

                    if let description = author.description {
                        Text(description)
                    }

                    if !author.links.isEmpty {
                        ViewThatFits(in: .horizontal) {
                            HStack(spacing: .spacing(.small)) {
                                ForEach(author.links, id: \.title) {
                                    ExternalLinkButton(externalLink: $0)
                                }
                            }
                            VStack(alignment: .leading, spacing: .spacing(.medium)) {
                                ForEach(author.links, id: \.title) {
                                    ExternalLinkButton(externalLink: $0)
                                }
                            }
                        }
                        .padding(.vertical, .spacing(.xxxSmall))
                    }

                    Text(soundCountText)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .bold()
                }
                .padding(.horizontal, .spacing(.large))
                .padding(.top, .spacing(.small))
                .padding(.bottom, .spacing(.xxSmall))
            }
        }
    }

    struct PadHeader: View {

        let author: Author
        let title: String
        let soundCount: Int
        let soundCountText: String
        let containerWidth: CGFloat

        let contentListMode: ContentGridMode
        @Binding var contentSortOption: Int
        let multiSelectAction: () -> Void
        let askForSoundAction: () -> Void
        let reportIssueAction: () -> Void
        let contentSortChangeAction: () -> Void

        private let textHorizontalOffset: CGFloat = 230

        private var hasPhoto: Bool {
            author.photo != nil
        }

        @Environment(\.colorScheme) private var colorScheme

        // MARK: - View Body

        var body: some View {
            if !hasPhoto || containerWidth < 400 {
                PhoneHeader(
                    author: author,
                    title: title,
                    soundCount: soundCount,
                    soundCountText: soundCountText,
                    contentListMode: contentListMode,
                    contentSortOption: $contentSortOption,
                    multiSelectAction: multiSelectAction,
                    askForSoundAction: askForSoundAction,
                    reportIssueAction: reportIssueAction,
                    contentSortChangeAction: contentSortChangeAction
                )
            } else {
                VStack(spacing: .zero) {
                    if let photo = author.photo, let photoUrl = URL(string: photo) {
                        StickyPhotoView(
                            photoUrl: photoUrl,
                            height: 200,
                            blurAndDarken: true
                        )
                        .overlay(alignment: .bottom) {
                            HStack(spacing: .zero) {
                                Spacer()
                                    .frame(width: textHorizontalOffset)

                                Text(title)
                                    .font(.largeTitle)
                                    .bold()
                                    .foregroundStyle(.white)
                                    .shadow(color: .black, radius: 4, x: 2, y: 2)

                                Spacer()
                            }
                            .padding(.bottom, .spacing(.small))
                        }
                        .overlay(alignment: .bottom) {
                            HStack {
                                if let photo = author.photo, let photoUrl = URL(string: photo) {
                                    KFImage(photoUrl)
                                        .placeholder {
                                            Image(systemName: "person.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 100)
                                                .foregroundColor(.gray)
                                                .opacity(0.3)
                                        }
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 150, height: 150)
                                        .clipShape(.circle)
                                        .background {
                                            Circle()
                                                .fill(colorScheme == .dark ? Color.black : Color.white)
                                                .frame(width: 170, height: 170)
                                        }
                                        .padding(.leading, .spacing(.medium))
                                }

                                Spacer()
                            }
                            .padding(.horizontal, .spacing(.xLarge))
                            .offset(y: 70)
                        }
                    }

                    HStack(spacing: .zero) {
                        Spacer()
                            .frame(width: textHorizontalOffset)

                        HStack {
                            VStack(alignment: .leading, spacing: .spacing(.medium)) {
                                if let description = author.description {
                                    Text(description)
                                }

                                if !author.links.isEmpty {
                                    ViewThatFits(in: .horizontal) {
                                        HStack(spacing: .spacing(.small)) {
                                            ForEach(author.links, id: \.title) {
                                                ExternalLinkButton(externalLink: $0)
                                            }
                                        }
                                        VStack(alignment: .leading, spacing: .spacing(.medium)) {
                                            ForEach(author.links, id: \.title) {
                                                ExternalLinkButton(externalLink: $0)
                                            }
                                        }
                                    }
                                    .padding(.vertical, .spacing(.xxxSmall))
                                }

                                Text(soundCountText)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .bold()
                            }

                            Spacer()

                            VStack {
                                MoreOptionsMenu(
                                    soundCount: soundCount,
                                    contentListMode: contentListMode,
                                    contentSortOption: $contentSortOption,
                                    multiSelectAction: multiSelectAction,
                                    askForSoundAction: askForSoundAction,
                                    reportIssueAction: reportIssueAction,
                                    contentSortChangeAction: contentSortChangeAction
                                )

                                Spacer()
                            }
                        }
                        .padding(.top, .spacing(.large))
                        .padding(.trailing, .spacing(.xLarge))
                        .padding(.bottom, .spacing(.small))
                    }
                }
            }
        }
    }

    struct MoreOptionsMenu: View {

        let soundCount: Int
        let contentListMode: ContentGridMode
        @Binding var contentSortOption: Int
        let multiSelectAction: () -> Void
        let askForSoundAction: () -> Void
        let reportIssueAction: () -> Void
        let contentSortChangeAction: () -> Void

        @ScaledMetric private var menuButtonHeight: CGFloat = 26

        // MARK: - View Body

        var body: some View {
            Menu {
                if soundCount > 1 {
                    Section {
                        Button {
                            multiSelectAction()
                        } label: {
                            Label(
                                contentListMode == .selection ? "Cancelar Seleção" : "Selecionar",
                                systemImage: contentListMode == .selection ? "xmark.circle" : "checkmark.circle"
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
                        askForSoundAction()
                    } label: {
                        Label("Pedir Som Desse Autor", systemImage: "plus.circle")
                    }

                    Button {
                        reportIssueAction()
                    } label: {
                        Label("Relatar Problema com os Detalhes Desse Autor", systemImage: "person.crop.circle.badge.exclamationmark")
                    }
                }

                if soundCount > 1 {
                    Section {
                        Picker("Ordenação de Sons", selection: $contentSortOption) {
                            Text("Título")
                                .tag(0)

                            Text("Mais Recentes no Topo")
                                .tag(1)
                        }
                        .onChange(of: contentSortOption) {
                            contentSortChangeAction()
                        }
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: menuButtonHeight)
            }
            .disabled(soundCount == 0)
        }
    }
}

// MARK: - Previews

#Preview("Name Only") {
    let author = Author(
        id: "0D944922-7E50-4DED-A8FD-F44EFCAE82A2",
        name: "Abraham Weintraub"
    )

    return GeometryReader { geometry in
        ScrollView {
            VStack(spacing: .spacing(.medium)) {
                AuthorHeaderView(
                    author: author,
                    title: author.name,
                    soundCount: 10,
                    soundCountText: "10 SONS",
                    contentListMode: .regular,
                    contentSortOption: .constant(0),
                    multiSelectAction: {},
                    askForSoundAction: {},
                    reportIssueAction: {},
                    contentSortChangeAction: {}
                )

                HStack(spacing: .spacing(.xLarge)) {
                    ForEach(0..<5) { _ in
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.green)
                            .frame(width: 200, height: 100)
                    }
                }
                //.border(.red, width: 1)
            }
            //.border(.blue, width: 1)
        }
    }
}

#Preview("Name & Description") {
    let author = Author(
        id: "0D944922-7E50-4DED-A8FD-F44EFCAE82A2",
        name: "Abraham Weintraub",
        description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam."
    )

    return GeometryReader { geometry in
        ScrollView {
            VStack(spacing: .spacing(.medium)) {
                AuthorHeaderView(
                    author: author,
                    title: author.name,
                    soundCount: 10,
                    soundCountText: "10 SONS",
                    contentListMode: .regular,
                    contentSortOption: .constant(0),
                    multiSelectAction: {},
                    askForSoundAction: {},
                    reportIssueAction: {},
                    contentSortChangeAction: {}
                )

                HStack(spacing: .spacing(.xLarge)) {
                    ForEach(0..<3) { _ in
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.green)
                            .frame(width: 200, height: 100)
                    }
                }
                //.border(.red, width: 1)
            }
            //.border(.blue, width: 1)
        }
    }
}

#Preview("Name, Description & External Links") {
    let author = Author(
        id: "0D944922-7E50-4DED-A8FD-F44EFCAE82A2",
        name: "Abraham Weintraub",
        description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.",
        externalLinks: "[{\"link\":\"https:\\/\\/www.twitch.tv\\/assimdisseojoao\",\"symbol\":\"twitch.png\",\"color\":\"purple\",\"title\":\"Twitch\"},{\"symbol\":\"youtube-full-color.png\",\"link\":\"https:\\/\\/www.youtube.com\\/channel\\/UC7-Pp09PJX_SYP9oyMzUAtg\",\"color\":\"red\",\"title\":\"YouTube\"},{\"link\":\"https:\\/\\/www.instagram.com\\/assimdisseojoao\\/\",\"symbol\":\"instagram-orange.png\",\"title\":\"Instagram\",\"color\":\"orange\"}]"
    )

    return GeometryReader { geometry in
        ScrollView {
            VStack(spacing: .spacing(.medium)) {
                AuthorHeaderView(
                    author: author,
                    title: author.name,
                    soundCount: 10,
                    soundCountText: "10 SONS",
                    contentListMode: .regular,
                    contentSortOption: .constant(0),
                    multiSelectAction: {},
                    askForSoundAction: {},
                    reportIssueAction: {},
                    contentSortChangeAction: {}
                )

                HStack(spacing: .spacing(.xLarge)) {
                    ForEach(0..<5) { _ in
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.green)
                            .frame(width: 200, height: 100)
                    }
                }
                //.border(.red, width: 1)
            }
            //.border(.blue, width: 1)
        }
    }
}

#Preview("Name, Description & Photo") {
    let author = Author(
        id: "0D944922-7E50-4DED-A8FD-F44EFCAE82A2",
        name: "Eduardo Pazuello",
        photo: "https://estaticos.globoradio.globo.com/fotos/2021/05/56a6514b-b5d7-410f-9638-8317408a710d.jpg.400x400_q75_box-669%2C0%2C3342%2C2674_crop_detail.jpg",
        description: "General do Exército Brasileiro. Foi ministro da Saúde do Brasil durante a pandemia de COVID-19 no país, entre 2020 e 2021."
    )

    return GeometryReader { geometry in
        ScrollView {
            VStack(spacing: .spacing(.medium)) {
                AuthorHeaderView(
                    author: author,
                    title: author.name,
                    soundCount: 10,
                    soundCountText: "10 SONS",
                    contentListMode: .regular,
                    contentSortOption: .constant(0),
                    multiSelectAction: {},
                    askForSoundAction: {},
                    reportIssueAction: {},
                    contentSortChangeAction: {}
                )

                HStack(spacing: .spacing(.xLarge)) {
                    ForEach(0..<3) { _ in
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.green)
                            .frame(width: 200, height: 100)
                    }
                }
                //.border(.red, width: 1)
            }
            //.border(.blue, width: 1)
        }
    }
}

#Preview("Name & Photo") {
    let author = Author(
        id: "0D944922-7E50-4DED-A8FD-F44EFCAE82A2",
        name: "Antonio Tabet",
        photo: "https://p2.trrsf.com/image/fget/cf/648/0/images.terra.com/2021/08/10/250817413-antonio-tabet.jpg"
    )

    return GeometryReader { geometry in
        ScrollView {
            VStack(spacing: .spacing(.medium)) {
                AuthorHeaderView(
                    author: author,
                    title: author.name,
                    soundCount: 6,
                    soundCountText: "6 SONS",
                    contentListMode: .regular,
                    contentSortOption: .constant(0),
                    multiSelectAction: {},
                    askForSoundAction: {},
                    reportIssueAction: {},
                    contentSortChangeAction: {}
                )

                HStack(spacing: .spacing(.xLarge)) {
                    ForEach(0..<5) { _ in
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.green)
                            .frame(width: 200, height: 100)
                    }
                }
                //.border(.red, width: 1)
            }
            //.border(.blue, width: 1)
        }
    }
}

#Preview("Photo No Longer Exists") {
    let author = Author(
        id: "0D944922-7E50-4DED-A8FD-F44EFCAE82A2",
        name: "Anderson Gaveta",
        photo: "https://yt3.googleusercontent.com/1uUc5OT51KnlcmN4nAcM-Wr3QSF6aLtp2IONCGHpleaZ6wjoU1inAQ21tdrXu2OxP1r9eyuRgA=s900-c-k-c0x00ffffff-no-rj",
        description: "Influenciador brasileiro que trabalha com foco em edição de vídeo e audiovisual."
    )

    return GeometryReader { geometry in
        ScrollView {
            VStack(spacing: .spacing(.medium)) {
                AuthorHeaderView(
                    author: author,
                    title: author.name,
                    soundCount: 6,
                    soundCountText: "6 SONS",
                    contentListMode: .regular,
                    contentSortOption: .constant(0),
                    multiSelectAction: {},
                    askForSoundAction: {},
                    reportIssueAction: {},
                    contentSortChangeAction: {}
                )

                HStack(spacing: .spacing(.xLarge)) {
                    ForEach(0..<5) { _ in
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.green)
                            .frame(width: 200, height: 100)
                    }
                }
                //.border(.red, width: 1)
            }
            //.border(.blue, width: 1)
        }
    }
}

#Preview("Name, Description, External Links & Photo") {
    let author = Author(
        id: "0D944922-7E50-4DED-A8FD-F44EFCAE82A2",
        name: "Calcinha Preta",
        photo: "https://s2-g1.glbimg.com/eQcCGY4iT5uT43zEstd6FewwRgk=/1200x/smart/filters:cover():strip_icc()/i.s3.glbimg.com/v1/AUTH_59edd422c0c84a879bd37670ae4f538a/internal_photos/bs/2023/N/N/ABoZHTQcu8Pzzu3B8vPg/calcinhapreta-novaformacao.jpg",
        description: "Banda de forró eletrônico formada em 1995 na cidade de Aracaju, SE.",
        externalLinks: "[{\"link\":\"https:\\/\\/www.twitch.tv\\/assimdisseojoao\",\"symbol\":\"twitch.png\",\"color\":\"purple\",\"title\":\"Twitch\"},{\"symbol\":\"youtube-full-color.png\",\"link\":\"https:\\/\\/www.youtube.com\\/channel\\/UC7-Pp09PJX_SYP9oyMzUAtg\",\"color\":\"red\",\"title\":\"YouTube\"},{\"link\":\"https:\\/\\/www.instagram.com\\/assimdisseojoao\\/\",\"symbol\":\"instagram-orange.png\",\"title\":\"Instagram\",\"color\":\"orange\"}]"
    )

    return GeometryReader { geometry in
        ScrollView {
            VStack(spacing: .spacing(.medium)) {
                AuthorHeaderView(
                    author: author,
                    title: author.name,
                    soundCount: 10,
                    soundCountText: "10 SONS",
                    contentListMode: .regular,
                    contentSortOption: .constant(0),
                    multiSelectAction: {},
                    askForSoundAction: {},
                    reportIssueAction: {},
                    contentSortChangeAction: {}
                )

                HStack(spacing: .spacing(.xLarge)) {
                    ForEach(0..<1) { _ in
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.green)
                            .frame(width: 200, height: 100)
                    }
                }
            }
        }
    }
}

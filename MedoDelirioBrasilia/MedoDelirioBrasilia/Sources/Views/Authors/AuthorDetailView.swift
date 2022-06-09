import SwiftUI

struct AuthorDetailView: View {

    @StateObject private var viewModel = AuthorDetailViewViewModel()
    @State var author: Author
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            if viewModel.sounds.count == 0 {
                NoSoundsView()
                    .padding(.horizontal, 25)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(viewModel.sounds) { sound in
                            SoundCell(soundId: sound.id, title: sound.title, author: sound.authorName ?? "", favorites: $viewModel.favoritesKeeper)
                                .onTapGesture {
                                    viewModel.playSound(fromPath: sound.filename)
                                }
                                .onLongPressGesture {
                                    viewModel.soundForConfirmationDialog = sound
                                    viewModel.showConfirmationDialog = true
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 7)
                    
                    Text(viewModel.getSoundCount())
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                        .padding(.bottom, 18)
                }
            }
        }
        .navigationTitle(author.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.reloadList(withSounds: soundData.filter({ $0.authorId == author.id }),
                                 andFavorites: try? database.getAllFavorites(),
                                 allowSensitiveContent: UserSettings.getShowOffensiveSounds())
        }
        .confirmationDialog("", isPresented: $viewModel.showConfirmationDialog) {
            Button(viewModel.getFavoriteButtonTitle()) {
                guard let sound = viewModel.soundForConfirmationDialog else {
                    return
                }
                if viewModel.isSelectedSoundAlreadyAFavorite() {
                    viewModel.removeFromFavorites(soundId: sound.id)
                } else {
                    viewModel.addToFavorites(soundId: sound.id)
                }
            }
            
            Button("Sugerir Outro Nome de Autor") {
                guard let sound = viewModel.soundForConfirmationDialog else {
                    return
                }
                SoundOptionsHelper.suggestOtherAuthorName(soundId: sound.id, soundTitle: sound.title, currentAuthorName: sound.authorName ?? .empty)
            }
            
            Button("Compartilhar") {
                guard let sound = viewModel.soundForConfirmationDialog else {
                    return
                }
                viewModel.shareSound(withPath: sound.filename, andContentId: sound.id)
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
    }

}

struct AuthorDetailView_Previews: PreviewProvider {

    static var previews: some View {
        AuthorDetailView(author: Author(id: "A", name: "João"))
    }

}

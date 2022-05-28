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
                
                Text("\(viewModel.sounds.count) sons")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
                    .padding(.bottom, 18)
            }
        }
        .navigationTitle(author.name)
        .onAppear {
            viewModel.reloadList(withSounds: soundData.filter({ $0.authorId == author.id }),
                                 andFavorites: try? database.getAllFavorites(),
                                 allowSensitiveContent: UserSettings.getShowOffensiveSounds())
        }
    }

}

struct AuthorDetailView_Previews: PreviewProvider {

    static var previews: some View {
        AuthorDetailView(author: Author(id: "A", name: "João"))
    }

}

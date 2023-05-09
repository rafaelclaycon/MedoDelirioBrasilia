//
//  SoundList.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 28/04/23.
//

import SwiftUI

struct SoundList: View {
    
    @State var sounds: [Sound] = []
    @StateObject var viewModel = SoundsViewViewModel(soundSortOption: 0, authorSortOption: 0, currentSoundsListMode: .constant(.regular))
    
    private let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                if sounds.count == 0 {
                    VStack {
                        HStack(spacing: 10) {
                            ProgressView()
                            
                            Text("Obtendo sons...")
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(width: geometry.size.width)
                    .frame(minHeight: geometry.size.height)
                } else {
                    LazyVGrid(columns: columns, spacing: UIDevice.current.userInterfaceIdiom == .phone ? 14 : 20) {
                        ForEach(sounds) { sound in
                            SoundCell(soundId: sound.id,
                                      title: sound.title,
                                      author: sound.authorName ?? "",
                                      duration: sound.duration,
                                      isNew: sound.isNew ?? false,
                                      favorites: .constant(Set<String>()),
                                      highlighted: .constant(Set<String>()),
                                      nowPlaying: .constant(Set<String>()),
                                      selectedItems: .constant(Set<String>()),
                                      currentSoundsListMode: .constant(.regular))
                                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 0 : 5)
                                .onTapGesture {
                                    viewModel.play(sound: sound)
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 7)
                }
            }
            .onAppear {
                fetchSounds()
            }
        }
    }
    
    func fetchSounds() {
        Task {
            do {
                let service = SyncService(connectionManager: ConnectionManager.shared,
                                          networkRabbit: networkRabbit,
                                          localDatabase: database)
                let syncResult = await service.syncWithServer()

                print(syncResult)
                
                //print(Date.now.iso8601withFractionalSeconds)
                
                var allSounds = try database.allSounds()
                
                for i in 0...(allSounds.count - 1) {
                    allSounds[i].authorName = authorData.first(where: { $0.id == allSounds[i].authorId })?.name ?? Shared.unknownAuthor
                }
                
                allSounds.sort(by: { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() })
                
                sounds = allSounds
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct SoundList_Previews: PreviewProvider {
    
    static var previews: some View {
        SoundList()
    }
}

//
//  SoundList.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 28/04/23.
//

import SwiftUI

struct SoundList: View {
    
    @Binding var updateList: Bool
    
    @State var sounds: [Sound] = []
    @StateObject var viewModel = SoundsViewViewModel(soundSortOption: 0, authorSortOption: 0, currentSoundsListMode: .constant(.regular))
    @State var showUpdatingView: Bool = false
    @State var currentAmount = 0.0
    @State var totalAmount = 0.0
    @AppStorage("lastUpdateDate") private var lastUpdateDate = "all"
    @State private var localUnsuccessfulUpdates: [UpdateEvent]? = nil
    @State private var serverUpdates: [UpdateEvent]? = nil
    @State private var showSyncProgressView = false
    
    private let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    
    private let service = SyncService(connectionManager: ConnectionManager.shared,
                                      networkRabbit: networkRabbit,
                                      localDatabase: LocalDatabase.shared)
    
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
                    if showSyncProgressView {
                        SyncProgressView(isBeingShown: $showSyncProgressView, currentAmount: $currentAmount, totalAmount: $totalAmount)
                    }
                    
                    LazyVGrid(columns: columns, spacing: UIDevice.current.userInterfaceIdiom == .phone ? 14 : 20) {
                        ForEach(sounds) { sound in
                            SoundCell(sound: sound,
                                      favorites: .constant(Set<String>()),
                                      highlighted: .constant(Set<String>()),
                                      nowPlaying: .constant(Set<String>()),
                                      selectedItems: .constant(Set<String>()),
                                      currentSoundsListMode: .constant(.regular))
                                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 0 : 5)
                                .onTapGesture {
                                    dump(sound)
                                    viewModel.play(sound)
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 7)
                }
            }
            .onChange(of: updateList) { updateList in
                if updateList {
                    loadLocalSounds()
                }
            }
        }
    }
    
    func loadLocalSounds() {
//        Task {
//            print("loadLocalSounds()")
//            
//            do {
//                var allSounds = try LocalDatabase.shared.allSounds()
//                allSounds.sort(by: { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() })
//                
//                await MainActor.run {
//                    sounds = allSounds
//                }
//            } catch {
//                print(error)
//            }
//        }
    }
}

struct SoundList_Previews: PreviewProvider {
    
    static var previews: some View {
        SoundList(updateList: .constant(false))
    }
}

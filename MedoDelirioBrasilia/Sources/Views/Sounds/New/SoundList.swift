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
    @State var showUpdatingView: Bool = false
    @State var currentAmount = 0.0
    @State var totalAmount = 0.0
    @AppStorage("lastUpdateDate") private var lastUpdateDate = "all"
    @State private var updates: [UpdateEvent]? = nil
    @State private var showSyncProgressView = false
    
    private let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    
    private let service = SyncService(connectionManager: ConnectionManager.shared,
                                      networkRabbit: networkRabbit,
                                      localDatabase: database)
    
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
                                    //dump(sound)
                                    viewModel.play(sound: sound)
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 7)
                }
            }
            .onAppear {
                Task { @MainActor in
                    if await loadLocalSounds() {
                        do {
                            let result = try await fetchUpdates()
                            print("Resultado do fetchUpdates: \(result)")
                            if result > 0 {
                                await MainActor.run {
                                    showSyncProgressView = true
                                    totalAmount = result
                                }
                                try await sync()
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        }
    }
    
    func fetchUpdates() async throws -> Double {
        print("fetchUpdates()")
        showUpdatingView = true
        updates = try await service.getUpdates(from: lastUpdateDate)
        return Double(updates?.count ?? 0)
    }
    
    func sync() async throws {
        print("sync()")
        guard let updates = updates else { return }
        guard updates.isEmpty == false else {
            return print("NO UPDATES")
        }
        guard service.hasConnectivity() else {
            throw SyncError.noInternet
        }
        
        currentAmount = 0.0
        for update in updates {
            await service.process(updateEvent: update)
            sleep(1)
            await MainActor.run {
                currentAmount += 1.0
            }
        }
        
        lastUpdateDate = Date.now.iso8601withFractionalSeconds
        
        _ = await loadLocalSounds()
        //print(Date.now.iso8601withFractionalSeconds)
    }
    
    func loadLocalSounds() async -> Bool {
        print("loadLocalSounds()")
        
        do {
            var allSounds = try database.allSounds()
            
            for i in 0...(allSounds.count - 1) {
                allSounds[i].authorName = authorData.first(where: { $0.id == allSounds[i].authorId })?.name ?? Shared.unknownAuthor
            }
            
            allSounds.sort(by: { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() })
            
            await MainActor.run {
                sounds = allSounds
            }
        } catch {
            print(error)
            return false
        }
        
        return true
    }
}

struct SoundList_Previews: PreviewProvider {
    
    static var previews: some View {
        SoundList()
    }
}

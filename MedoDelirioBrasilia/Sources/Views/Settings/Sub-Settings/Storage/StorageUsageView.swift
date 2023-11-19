//
//  StorageUsageView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 18/11/23.
//

import SwiftUI

struct StorageUsageView: View {

    @State private var totalDiskSpace: String = ""

    @State private var soundsDiskSpace: String = ""
    @State private var songsDiskSpace: String = ""
    @State private var exportedVideosDiskSpace: String = ""

    var body: some View {
        Form {
            HStack {
                Image(systemName: "speaker.wave.3").foregroundStyle(.green)
                Text("Sons Baixados")

                Spacer()

                Text(soundsDiskSpace)
            }

            HStack {
                Image(systemName: "music.quarternote.3").foregroundStyle(.pink)
                Text("Músicas Baixadas")

                Spacer()

                Text(songsDiskSpace)
            }

            HStack {
                Image(systemName: "film").foregroundStyle(.blue)
                Text("Vídeos Exportados")

                Spacer()

                Text(exportedVideosDiskSpace)
            }
        }
        .navigationTitle("Uso do armazenamento")
        .onAppear {
            Task {
                totalDiskSpace = "\(UIDevice.current.totalDiskSpaceInGB)"
                
                soundsDiskSpace = size(for: "downloaded_sounds")
                songsDiskSpace = size(for: "downloaded_songs")
            }
        }
    }

    private func size(for folderName: String) -> String {
        do {
            let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let downloadedSoundsDir = documentsUrl.appendingPathComponent(folderName)
            return try downloadedSoundsDir.sizeOnDisk() ?? ""
        } catch {
            print(error)
            return ""
        }
    }
}

#Preview {
    StorageUsageView()
}

//
//  NewSoundsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 28/04/23.
//

import SwiftUI

struct NewSoundsView: View {
    
    var body: some View {
        ZStack {
            VStack {
                SoundList()
            }
            .navigationTitle(Text("Sons"))
        }
    }
}

struct NewSoundsView_Previews: PreviewProvider {
    
    static var previews: some View {
        NewSoundsView()
    }
}

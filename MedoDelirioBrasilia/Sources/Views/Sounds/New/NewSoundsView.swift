//
//  NewSoundsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 28/04/23.
//

import SwiftUI

struct NewSoundsView: View {
    
    @Binding var updateList: Bool
    
    var body: some View {
        ZStack {
            VStack {
                SoundList(updateList: $updateList)
            }
            .navigationTitle(Text("Sons"))
        }
    }
}

struct NewSoundsView_Previews: PreviewProvider {
    
    static var previews: some View {
        NewSoundsView(updateList: .constant(false))
    }
}

//
//  BetaTagView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 04/08/23.
//

import SwiftUI

struct BetaTagView: View {

    var body: some View {
        Text("BETA")
            .foregroundColor(.white)
            .font(.footnote)
            .bold()
            .padding(.all, 5)
            .background {
                RoundedRectangle(cornerRadius: 6)
                    .foregroundColor(.blue)
            }
    }
}

struct BetaTagView_Previews: PreviewProvider {

    static var previews: some View {
        BetaTagView()
    }
}

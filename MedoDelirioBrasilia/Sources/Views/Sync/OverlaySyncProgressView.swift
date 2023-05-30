//
//  OverlaySyncProgressView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 29/05/23.
//

import SwiftUI

struct OverlaySyncProgressView: View {
    
    @State var message: String
    @State var progressViewYOffset: CGFloat = -20
    @State var progressViewWidth: CGFloat = 200
    @State var messageYOffset: CGFloat = 33
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(0.6)
                .ignoresSafeArea()
            
            ProgressView()
                .scaleEffect(2, anchor: .center)
                .frame(width: progressViewWidth, height: 140)
                .offset(x: 0, y: progressViewYOffset)
                .background(.regularMaterial)
                .cornerRadius(25)
            
            Text(message)
                .offset(x: 0, y: messageYOffset)
                .multilineTextAlignment(.center)
        }
    }
}

struct OverlaySyncProgressView_Previews: PreviewProvider {
    
    static var previews: some View {
        OverlaySyncProgressView(message: "Atualizando dados...")
    }
}

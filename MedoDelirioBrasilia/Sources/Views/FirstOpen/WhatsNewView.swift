//
//  WhatsNewView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 14/02/23.
//

import SwiftUI

struct WhatsNewView: View {
    
    @Binding var isBeingShown: Bool
    
    private var spacingTopBottom: CGFloat {
        100
    }
    
    private var systemName: String {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return "iOS 16"
        } else {
            return ProcessInfo.processInfo.isiOSAppOnMac ? "macOS Ventura" : "iPadOS 16"
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 50) {
                Text("Novidade da Versão 6.3")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                VStack(alignment: .center, spacing: 24) {
                    HStack(spacing: 15) {
                        Image(systemName: "film")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40)
                            .foregroundColor(.green)
                            .padding(.horizontal, 6)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Melhorias no Compartilhar como Vídeo")
                                .font(.callout)
                                .bold()
                            Text("Agora os vídeos contam com o nome do(a) autor(a) e uma fonte de texto mais bonita. Requer \(systemName).")
                                .font(.callout)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
//                    HStack(spacing: 15) {
//                        Image(systemName: "folder.fill")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 40)
//                            .foregroundColor(.green)
//                            .padding(.horizontal, 4)
//
//                        VStack(alignment: .leading, spacing: 5) {
//                            Text("Pastas Mais Espertas")
//                                .font(.callout)
//                                .bold()
//                            Text("Ordene o conteúdo da pasta pela data na qual o som foi adicionado a ela. Disponível para pastas criadas a partir da versão 5.47.")
//                                .font(.callout)
//                                .foregroundColor(.gray)
//                        }
//
//                        Spacer()
//                    }
//
//                    HStack(spacing: 15) {
//                        Image(systemName: "person.crop.artframe")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 36)
//                            .foregroundColor(.green)
//                            .padding(.horizontal, 6)
//
//                        VStack(alignment: .leading, spacing: 5) {
//                            Text("Nova Experiência de Autor")
//                                .font(.callout)
//                                .bold()
//                            Text("Veja uma foto e uma breve descrição da relevância da pessoa ao abrir a tela de autor de cada som.")
//                                .font(.callout)
//                                .foregroundColor(.gray)
//                        }
//
//                        Spacer()
//                    }
                }
                .padding(.horizontal, 20)
                
                Button {
                    AppPersistentMemory.setHasSeen63WhatsNewScreen(to: true)
                    isBeingShown = false
                } label: {
                    Text("Continuar")
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                .tint(.accentColor)
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 15))
                .padding(.horizontal, 24)
                .padding(.top)
            }
            .padding(.top, spacingTopBottom)
            .padding(.bottom, spacingTopBottom)
        }
    }
    
}

struct WhatsNewView_Previews: PreviewProvider {
    
    static var previews: some View {
        WhatsNewView(isBeingShown: .constant(true))
    }
    
}

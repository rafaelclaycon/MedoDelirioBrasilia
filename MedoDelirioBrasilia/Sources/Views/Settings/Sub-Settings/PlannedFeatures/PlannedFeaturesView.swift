//
//  PlannedFeaturesView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 27/02/23.
//

import SwiftUI
import Roadmap

struct PlannedFeaturesView: View {
    
    let configuration = RoadmapConfiguration(roadmapJSONURL: URL(string: "https://simplejsoncms.com/api/m8v58wbd4jf")!)
    
    var body: some View {
        NavigationView {
            RoadmapView(
                configuration: configuration,
                header: {
                    GroupBox {
                        HStack {
                            Text("Vote nas funcionalidades que gostaria de ver no app. Sou apenas 1 dev, então não posso garantir se e quando ela aparecerá no app.")
                                .padding(10)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    }.padding(.vertical, 20)
                }, footer: {
                    HStack {
                        Spacer()
                        Text("Votação criada com [Roadmap](https://github.com/AvdLee/Roadmap)")
                        Spacer()
                    }.padding(.vertical, 10)
                })
        }
        .navigationTitle("Planejamento")
    }
    
}

struct PlannedFeaturesView_Previews: PreviewProvider {
    
    static var previews: some View {
        PlannedFeaturesView()
    }
    
}

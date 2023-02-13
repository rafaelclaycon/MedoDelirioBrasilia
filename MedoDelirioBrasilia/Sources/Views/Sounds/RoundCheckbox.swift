//
//  RoundCheckbox.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 13/02/23.
//

import SwiftUI

struct RoundCheckbox: View {
    
    @Binding var selected: Bool
    @State var style: RoundCheckboxStyle

    private let circleSize: CGFloat = 28.0
    
    // Unchecked
    private let unselectedFillColor: Color = .systemBackground
    private let unselectedForegroundColor: Color = .gray
    
    // Checked
    private let selectedFillColor: Color = .pink
    private let selectedForegroundColor: Color = .systemBackground
    
    public enum RoundCheckboxStyle {
        case `default`, holePunch
    }
    
    var body: some View {
        ZStack {
            if style == .holePunch {
                Circle()
                    .fill(selectedForegroundColor)
                    .frame(width: circleSize, height: circleSize)
            }
            
            if selected {
                if style == .default {
                    Circle()
                        .fill(selectedFillColor)
                        .frame(width: circleSize, height: circleSize)
                }
                
                Image(systemName: "checkmark")
                    .foregroundColor(style == .holePunch ? selectedFillColor : unselectedFillColor)
                    .font(.title3.bold())
                    .frame(width: circleSize, height: circleSize)
            } else {
                Circle()
                    .stroke(unselectedForegroundColor, lineWidth: 1.7)
                    .frame(width: circleSize, height: circleSize)
                    .opacity(0.7)
            }
        }
        .onTapGesture {
            selected.toggle()
        }
    }

}

struct RoundCheckbox_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            // Unchecked
            RoundCheckbox(selected: .constant(false), style: .default)
            RoundCheckbox(selected: .constant(false), style: .holePunch)
            
            // Checked
            RoundCheckbox(selected: .constant(true), style: .default)
            RoundCheckbox(selected: .constant(true), style: .holePunch)
        }
        .previewLayout(.fixed(width: 80, height: 80))
    }

}

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
    @Environment(\.colorScheme) var colorScheme

    private let circleSize: CGFloat = 28.0
    
    // Unchecked
    private let unselectedFillColor: Color = .systemBackground
    private let unselectedForegroundColor: Color = .gray
    
    // Checked
    private let selectedFillColor: Color = .blue
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
                    .foregroundColor(.white)
                    .font(.system(size: 15).bold())
                    .frame(width: circleSize, height: circleSize)
            } else {
                Circle()
                    .stroke(colorScheme == .dark ? .white : .gray, lineWidth: 1.7)
                    .frame(width: circleSize, height: circleSize)
                    .opacity(colorScheme == .dark ? 1.0 : 0.7)
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

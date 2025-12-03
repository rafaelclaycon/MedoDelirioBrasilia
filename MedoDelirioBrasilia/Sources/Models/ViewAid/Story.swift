//
//  Story.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/11/25.
//

import SwiftUI

/// Represents a single story in the retrospective stories flow
struct Story: Identifiable, Equatable {
    let id: String
    let duration: TimeInterval
    let backgroundColor: StoryBackgroundStyle
    
    init(
        id: String,
        duration: TimeInterval = 5.0,
        backgroundColor: StoryBackgroundStyle = .solid(.black)
    ) {
        self.id = id
        self.duration = duration
        self.backgroundColor = backgroundColor
    }
    
    static func == (lhs: Story, rhs: Story) -> Bool {
        lhs.id == rhs.id
    }
}

/// Background style options for stories
enum StoryBackgroundStyle {
    case solid(Color)
    case gradient(Gradient, startPoint: UnitPoint, endPoint: UnitPoint)
    
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .solid(let color):
            color
        case .gradient(let gradient, let startPoint, let endPoint):
            LinearGradient(
                gradient: gradient,
                startPoint: startPoint,
                endPoint: endPoint
            )
        }
    }
}

/// Defines the different types of story pages in the retrospective
enum StoryPage: String, CaseIterable {
    case welcome
    case topSound1
    case topSound2
    case topSound3
    case stats
    case share
    
    var story: Story {
        switch self {
        case .welcome:
            return Story(
                id: "welcome",
                duration: 4.0,
                backgroundColor: .gradient(
                    Gradient(colors: [.darkestGreen, .green, .yellow]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .topSound1:
            return Story(id: "topSound1", duration: 5.0, backgroundColor: .solid(.darkerGreen))
        case .topSound2:
            return Story(id: "topSound2", duration: 5.0, backgroundColor: .solid(.darkerGreen))
        case .topSound3:
            return Story(id: "topSound3", duration: 5.0, backgroundColor: .solid(.green))
        case .stats:
            return Story(id: "stats", duration: 6.0, backgroundColor: .solid(.darkestGreen))
        case .share:
            return Story(
                id: "share",
                duration: 10.0,
                backgroundColor: .gradient(
                    Gradient(colors: [.yellow, .green, .darkestGreen]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
}


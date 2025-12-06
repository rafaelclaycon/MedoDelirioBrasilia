//
//  StoriesView+ViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/11/25.
//

import Foundation
import Combine

extension StoriesView {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        // MARK: - Published Properties
        
        @Published var stories: [Story] = []
        @Published var topSounds: [TopChartItem] = []
        @Published var topAuthor: TopAuthorItem?
        @Published var totalShareCount: Int = 0
        @Published var totalUniqueSoundsShared: Int = 0
        @Published var mostCommonShareDay: String = "-"
        @Published var isLoading: Bool = true
        
        // MARK: - Private Properties
        
        private let database: LocalDatabaseProtocol
        private var cancellables = Set<AnyCancellable>()
        
        // MARK: - Initializer
        
        init(database: LocalDatabaseProtocol = LocalDatabase.shared) {
            self.database = database
        }
        
        // MARK: - Public Methods
        
        func loadData() async {
            isLoading = true
            
            // Load top sounds
            do {
                topSounds = try database.getTopSoundsSharedByTheUser(5)
            } catch {
                print("Error loading top sounds: \(error)")
                topSounds = []
            }
            
            // Load share counts
            totalShareCount = database.totalShareCount()
            totalUniqueSoundsShared = database.sharedSoundsCount()
            
            // Load top author
            topAuthor = try? database.getTopAuthorSharedByTheUser()
            
            // Load most common share day
            do {
                let dates = try database.allDatesInWhichTheUserShared()
                mostCommonShareDay = mostCommonDay(from: dates) ?? "-"
            } catch {
                print("Error loading share dates: \(error)")
                mostCommonShareDay = "-"
            }
            
            // Build stories array
            buildStories()
            
            isLoading = false
        }
        
        // MARK: - Private Methods
        
        private func buildStories() {
            var storyPages: [StoryPage] = []
            
            // Always include welcome
            storyPages.append(.welcome)
            
            // Add top sounds (up to 3)
            let topSoundsToShow = min(topSounds.count, 3)
            if topSoundsToShow >= 1 {
                storyPages.append(.topSound1)
            }
            if topSoundsToShow >= 2 {
                storyPages.append(.topSound2)
            }
            if topSoundsToShow >= 3 {
                storyPages.append(.topSound3)
            }
            
            // Add stats if user has shared anything
            if totalShareCount > 0 {
                storyPages.append(.stats)
            }
            
            // Always include share at the end
            storyPages.append(.share)
            
            stories = storyPages.map { $0.story }
        }
        
        private func mostCommonDay(from dates: [Date]) -> String? {
            guard !dates.isEmpty else { return nil }
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "pt-BR")
            dateFormatter.dateFormat = "EEEE"
            
            // Count occurrences of each day of the week
            var dayCounts: [String: Int] = [:]
            for date in dates {
                let dayName = dateFormatter.string(from: date)
                dayCounts[dayName, default: 0] += 1
            }
            
            // Find the most common day
            let mostCommon = dayCounts.max { $0.value < $1.value }
            return mostCommon?.key.capitalized
        }
        
        func topSound(at index: Int) -> TopChartItem? {
            guard index < topSounds.count else { return nil }
            return topSounds[index]
        }
    }
}


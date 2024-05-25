//
//  ContentSortOption.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/05/22.
//

import Foundation

enum SoundSortOption: Int {

    case titleAscending, authorNameAscending, dateAddedDescending, shortestFirst, longestFirst, longestTitleFirst, shortestTitleFirst

}

enum SongSortOption: Int {

    case titleAscending, dateAddedDescending, durationDescending, durationAscending

}

enum AuthorSortOption: Int {

    case nameAscending, soundCountDescending, soundCountAscending

}

enum FolderSoundSortOption: Int {

    case titleAscending, authorNameAscending, dateAddedDescending

}

//
//  ContentSortOption.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/05/22.
//

import Foundation

enum SoundSortOption: Int {

    case titleAscending, authorNameAscending, dateAddedDescending

}

enum SongSortOption: Int {

    case titleAscending, dateAddedDescending, durationDescending, durationAscending

}

enum AuthorSortOption: Int {

    case nameAscending, soundCountDescending, soundCountAscending

}

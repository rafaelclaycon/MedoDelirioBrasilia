//
//  LoadingState.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 14/04/24.
//

import Foundation

enum LoadingState<T: Equatable>: Equatable {

    case loading
    case loaded(T)
    case error(String)

    static func == (lhs: LoadingState<T>, rhs: LoadingState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.loaded(let lhsItems), .loaded(let rhsItems)):
            return lhsItems == rhsItems
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

enum ContentStatisticsState<T: Equatable>: Equatable {

    case loading
    case loaded(T)
    case noDataYet
    case error(String)

    static func == (lhs: ContentStatisticsState<T>, rhs: ContentStatisticsState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.loaded(let lhsItems), .loaded(let rhsItems)):
            return lhsItems == rhsItems
        case (.noDataYet, .noDataYet):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

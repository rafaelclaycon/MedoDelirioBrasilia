//
//  TopChartItem+.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 04/12/23.
//

import Foundation

extension Array where Element == TopChartItem {

    var ranked: [TopChartItem] {
        var newArray: [TopChartItem] = []
        for (index, element) in self.enumerated() {
            var newElement = element
            newElement.rankNumber = "\(index + 1)"
            newArray.append(newElement)
        }
        return newArray
    }
}

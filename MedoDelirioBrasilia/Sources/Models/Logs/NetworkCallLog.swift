//
//  NetworkCallLog.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 20/06/22.
//

import Foundation

struct NetworkCallLog: Hashable, Codable, Identifiable {

    var id: String
    var callType: Int
    var requestBody: String
    var response: String
    var dateTime: Date
    var wasSuccessful: Bool
    
    init(id: String = UUID().uuidString,
         callType: Int,
         requestBody: String,
         response: String,
         dateTime: Date,
         wasSuccessful: Bool) {
        self.id = id
        self.callType = callType
        self.requestBody = requestBody
        self.response = response
        self.dateTime = dateTime
        self.wasSuccessful = wasSuccessful
    }

}

enum NetworkCallType: Int {

    case checkServerStatus, postClientDeviceInfo, postShareCountStat, getSoundShareCountStats

}

//enum HTTPMethod: Int {
//
//    case get, post
//
//}

import Foundation

struct FavoriteLog: Hashable, Codable, Identifiable {

    var id: String
    var favoriteCount: Int
    var dateTime: Date
    var appVersion: String
    var deviceModel: String
    var systemVersion: String
    var callMoment: String
    var needsMigration: Bool
    var installId: String
    
    init(id: String = UUID().uuidString,
         favoriteCount: Int,
         dateTime: Date,
         appVersion: String,
         deviceModel: String,
         systemVersion: String,
         callMoment: String,
         needsMigration: Bool,
         installId: String) {
        self.id = id
        self.favoriteCount = favoriteCount
        self.dateTime = dateTime
        self.appVersion = appVersion
        self.deviceModel = deviceModel
        self.systemVersion = systemVersion
        self.callMoment = callMoment
        self.needsMigration = needsMigration
        self.installId = installId
    }

}

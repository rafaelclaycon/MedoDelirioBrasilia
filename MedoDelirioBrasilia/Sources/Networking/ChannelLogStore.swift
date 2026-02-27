import Foundation

struct ChannelLogEntry: Identifiable {

    let id = UUID()
    let timestamp: Date
    let method: String
    let url: String
    let requestBody: String?
    let statusCode: Int?
    let responseBody: String?
    let success: Bool
    let errorMessage: String?
}

@Observable
final class ChannelLogStore {

    static let shared = ChannelLogStore()

    private(set) var entries: [ChannelLogEntry] = []

    private init() {}

    func log(
        method: String,
        url: String,
        requestBody: String? = nil,
        statusCode: Int? = nil,
        responseBody: String? = nil,
        success: Bool,
        errorMessage: String? = nil
    ) {
        let entry = ChannelLogEntry(
            timestamp: .now,
            method: method,
            url: url,
            requestBody: requestBody,
            statusCode: statusCode,
            responseBody: responseBody,
            success: success,
            errorMessage: errorMessage
        )
        Task { @MainActor in
            self.entries.insert(entry, at: 0)
        }
    }
}

import Foundation

extension APIClient {

    func subscribeToChannel(_ channelId: String) async throws {
        let url = URL(string: serverPath + "v4/subscribe-channel")!
        let body = ChannelSubscription(
            installId: AppPersistentMemory.shared.customInstallId,
            channelId: channelId
        )
        try await post(to: url, body: body)
    }

    func unsubscribeFromChannel(_ channelId: String) async throws {
        let url = URL(string: serverPath + "v4/unsubscribe-channel")!
        let body = ChannelSubscription(
            installId: AppPersistentMemory.shared.customInstallId,
            channelId: channelId
        )
        try await post(to: url, body: body)
    }

    func deviceChannels() async throws -> [String] {
        let installId = AppPersistentMemory.shared.customInstallId
        let url = URL(string: serverPath + "v4/device-channels/\(installId)")!
        return try await get(from: url)
    }
}

import Foundation

enum EpisodeNotificationSubscriber {

    enum SubscriptionError: LocalizedError {

        case deviceNotRegistered

        var errorDescription: String? {
            switch self {
            case .deviceNotRegistered:
                return "O dispositivo ainda não foi registrado para notificações. Verifique se as notificações estão habilitadas e tente novamente."
            }
        }
    }

    static func subscribe() async -> Result<Void, Error> {
        guard AppPersistentMemory.shared.getLastSentPushToken() != nil else {
            return .failure(SubscriptionError.deviceNotRegistered)
        }

        do {
            try await APIClient.shared.subscribeToChannel("new_episodes")
            UserSettings().setEnableEpisodeNotifications(to: true)
            return .success(())
        } catch {
            UserSettings().setEnableEpisodeNotifications(to: false)
            return .failure(error)
        }
    }

    static func unsubscribe() async -> Result<Void, Error> {
        do {
            try await APIClient.shared.unsubscribeFromChannel("new_episodes")
            UserSettings().setEnableEpisodeNotifications(to: false)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}

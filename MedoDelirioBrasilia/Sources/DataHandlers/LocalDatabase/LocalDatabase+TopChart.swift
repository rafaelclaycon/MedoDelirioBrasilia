import Foundation
import SQLite

private typealias Expression = SQLite.Expression

// MARK: - Top Author Model

struct TopAuthorItem {
    let authorId: String
    let authorName: String
    let authorPhoto: String?
    let shareCount: Int
}

extension LocalDatabase {

    // MARK: - Personal Top Chart

    func getTopSoundsSharedByTheUser(_ limit: Int) throws -> [TopChartItem] {
        guard let firstDay2023 = "2024-01-01T00:00:00.000Z".iso8601withFractionalSeconds else { return [] }

        var result = [TopChartItem]()

        let content_id = Expression<String>("contentId")
        let content_type = Expression<Int>("contentType")

        let soundId = Expression<String>("id")
        let soundTitle = Expression<String>("title")
        let authorIdOnSounds = Expression<String>("authorId")

        let authorId = Expression<String>("id")
        let authorName = Expression<String>("name")

        let dateTime = Expression<Date>("dateTime")

        let contentCount = content_id.count
        for row in try db.prepare(
            userShareLog
                .join(soundTable, on: userShareLog[content_id] == soundTable[soundId])
                .join(author, on: soundTable[authorIdOnSounds] == author[authorId])
                .select(userShareLog[content_id], soundTable[soundTitle], soundTable[authorId], author[authorName], contentCount)
                .where(userShareLog[content_type] == 0 || userShareLog[content_type] == 2)
                .filter(dateTime > firstDay2023)
                .group(userShareLog[content_id])
                .order(contentCount.desc)
                .limit(limit)
        ) {
            result.append(
                TopChartItem(
                    id: "",
                    rankNumber: "",
                    contentId: row[content_id],
                    contentName: row[soundTable[soundTitle]],
                    contentAuthorId: row[soundTable[authorId]],
                    contentAuthorName: row[author[authorName]],
                    shareCount: row[contentCount]
                )
            )
        }
        return result
    }

    func getTopAuthorSharedByTheUser() throws -> TopAuthorItem? {
        guard let firstDay2024 = "2024-01-01T00:00:00.000Z".iso8601withFractionalSeconds else { return nil }

        let content_id = Expression<String>("contentId")
        let content_type = Expression<Int>("contentType")

        let soundId = Expression<String>("id")
        let authorIdOnSounds = Expression<String>("authorId")

        let authorId = Expression<String>("id")
        let authorName = Expression<String>("name")
        let authorPhoto = Expression<String?>("photo")

        let dateTime = Expression<Date>("dateTime")

        let contentCount = content_id.count

        // First try: Get top author WITH a photo
        let queryWithPhoto = userShareLog
            .join(soundTable, on: userShareLog[content_id] == soundTable[soundId])
            .join(author, on: soundTable[authorIdOnSounds] == author[authorId])
            .select(author[authorId], author[authorName], author[authorPhoto], contentCount)
            .where(userShareLog[content_type] == 0 || userShareLog[content_type] == 2)
            .filter(dateTime > firstDay2024)
            .filter(author[authorPhoto] != nil && author[authorPhoto] != "")
            .group(author[authorId])
            .order(contentCount.desc)
            .limit(1)

        for row in try db.prepare(queryWithPhoto) {
            return TopAuthorItem(
                authorId: row[author[authorId]],
                authorName: row[author[authorName]],
                authorPhoto: row[author[authorPhoto]],
                shareCount: row[contentCount]
            )
        }

        // Fallback: Get top author without photo requirement
        let queryAny = userShareLog
            .join(soundTable, on: userShareLog[content_id] == soundTable[soundId])
            .join(author, on: soundTable[authorIdOnSounds] == author[authorId])
            .select(author[authorId], author[authorName], author[authorPhoto], contentCount)
            .where(userShareLog[content_type] == 0 || userShareLog[content_type] == 2)
            .filter(dateTime > firstDay2024)
            .group(author[authorId])
            .order(contentCount.desc)
            .limit(1)

        for row in try db.prepare(queryAny) {
            return TopAuthorItem(
                authorId: row[author[authorId]],
                authorName: row[author[authorName]],
                authorPhoto: row[author[authorPhoto]],
                shareCount: row[contentCount]
            )
        }

        return nil
    }

    func allDatesInWhichTheUserShared() throws -> [Date] {
        guard let firstDay2023 = "2024-01-01T00:00:00.000Z".iso8601withFractionalSeconds else { return [] }

        var result = [Date]()

        // let content_id = Expression<String>("contentId")
        let content_type = Expression<Int>("contentType")

        let date_time = Expression<Date>("dateTime")

        for row in try db.prepare(
            userShareLog
                .select(userShareLog[date_time])
                .where(userShareLog[content_type] == 0 || userShareLog[content_type] == 2)
                .filter(date_time > firstDay2023)
        ) {
            result.append(row[date_time])
        }
        return result
    }

    // MARK: - Audience Top Chart

    func getTop10SoundsSharedByTheAudience(for timeInterval: TrendsTimeInterval) throws -> [TopChartItem] {
        var result = [TopChartItem]()

        let content_id = Expression<String>("contentId")
        let content_type = Expression<Int>("contentType")
        let share_count = Expression<Int>("shareCount")
        let ranking_type = Expression<Int>("rankingType")

        let soundId = Expression<String>("id")
        let soundTitle = Expression<String>("title")
        let authorIdOnSounds = Expression<String>("authorId")

        let authorId = Expression<String>("id")
        let authorName = Expression<String>("name")

        let totalShareCount = share_count.sum
        for row in try db.prepare(
            audienceSharingStatistic
                .join(soundTable, on: audienceSharingStatistic[content_id] == soundTable[soundId])
                .join(author, on: soundTable[authorIdOnSounds] == author[authorId])
                .select(audienceSharingStatistic[content_id], soundTable[soundTitle], soundTable[authorId], author[authorName], totalShareCount)
                .where(audienceSharingStatistic[content_type] == 0)
                .where(audienceSharingStatistic[ranking_type] == timeInterval.rawValue)
                .group(audienceSharingStatistic[content_id])
                .order(totalShareCount.desc)
                .limit(10)
        ) {
            result.append(
                TopChartItem(
                    id: "",
                    rankNumber: "",
                    contentId: row[audienceSharingStatistic[content_id]],
                    contentName: row[soundTable[soundTitle]],
                    contentAuthorId: row[soundTable[authorId]],
                    contentAuthorName: row[author[authorName]],
                    shareCount: row[totalShareCount] ?? 0
                )
            )
        }
        return result
    }

    func sharedSoundsCount() -> Int {
        guard let firstDay2023 = "2024-01-01T00:00:00.000Z".iso8601withFractionalSeconds else { return 0 }

        let content_id = Expression<String>("contentId")
        let content_type = Expression<Int>("contentType")
        let dateTime = Expression<Date>("dateTime")

        let contentCount = content_id.distinct.count
        let query = userShareLog
            .select(contentCount)
            .where(content_type == 0 || content_type == 2)
            .filter(dateTime > firstDay2023)

        do {
            var count = 0
            for row in try db.prepare(query) {
                count = row[contentCount]
            }
            return count
        } catch {
            return 0
        }
    }

    func totalShareCount() -> Int {
        guard let firstDay2023 = "2024-01-01T00:00:00.000Z".iso8601withFractionalSeconds else { return 0 }

        let content_id = Expression<String>("contentId")
        let content_type = Expression<Int>("contentType")
        let dateTime = Expression<Date>("dateTime")

        let contentCount = content_id.count
        let query = userShareLog
            .select(contentCount)
            .where(content_type == 0 || content_type == 2)
            .filter(dateTime > firstDay2023)

        do {
            var count = 0
            for row in try db.prepare(query) {
                count = row[contentCount]
            }
            return count
        } catch {
            return 0
        }
    }

    // MARK: - Personal Top Chart 2025 Retrospective

    func getTopSoundsSharedByTheUserFor2025Retro(_ limit: Int) throws -> [TopChartItem] {
        guard let firstDay2025 = "2025-01-01T00:00:00.000Z".iso8601withFractionalSeconds,
              let lastDay2025 = "2026-01-01T00:00:00.000Z".iso8601withFractionalSeconds else { return [] }

        var result = [TopChartItem]()

        let content_id = Expression<String>("contentId")
        let content_type = Expression<Int>("contentType")

        let soundId = Expression<String>("id")
        let soundTitle = Expression<String>("title")
        let authorIdOnSounds = Expression<String>("authorId")

        let authorId = Expression<String>("id")
        let authorName = Expression<String>("name")

        let dateTime = Expression<Date>("dateTime")

        let contentCount = content_id.count
        for row in try db.prepare(
            userShareLog
                .join(soundTable, on: userShareLog[content_id] == soundTable[soundId])
                .join(author, on: soundTable[authorIdOnSounds] == author[authorId])
                .select(userShareLog[content_id], soundTable[soundTitle], soundTable[authorId], author[authorName], contentCount)
                .where(userShareLog[content_type] == 0 || userShareLog[content_type] == 2)
                .filter(dateTime >= firstDay2025 && dateTime < lastDay2025)
                .group(userShareLog[content_id])
                .order(contentCount.desc)
                .limit(limit)
        ) {
            result.append(
                TopChartItem(
                    id: "",
                    rankNumber: "",
                    contentId: row[content_id],
                    contentName: row[soundTable[soundTitle]],
                    contentAuthorId: row[soundTable[authorId]],
                    contentAuthorName: row[author[authorName]],
                    shareCount: row[contentCount]
                )
            )
        }
        return result
    }

    func getTopAuthorSharedByTheUserFor2025Retro() throws -> TopAuthorItem? {
        guard let firstDay2025 = "2025-01-01T00:00:00.000Z".iso8601withFractionalSeconds,
              let lastDay2025 = "2026-01-01T00:00:00.000Z".iso8601withFractionalSeconds else { return nil }

        let content_id = Expression<String>("contentId")
        let content_type = Expression<Int>("contentType")

        let soundId = Expression<String>("id")
        let authorIdOnSounds = Expression<String>("authorId")

        let authorId = Expression<String>("id")
        let authorName = Expression<String>("name")
        let authorPhoto = Expression<String?>("photo")

        let dateTime = Expression<Date>("dateTime")

        let contentCount = content_id.count

        // First try: Get top author WITH a photo
        let queryWithPhoto = userShareLog
            .join(soundTable, on: userShareLog[content_id] == soundTable[soundId])
            .join(author, on: soundTable[authorIdOnSounds] == author[authorId])
            .select(author[authorId], author[authorName], author[authorPhoto], contentCount)
            .where(userShareLog[content_type] == 0 || userShareLog[content_type] == 2)
            .filter(dateTime >= firstDay2025 && dateTime < lastDay2025)
            .filter(author[authorPhoto] != nil && author[authorPhoto] != "")
            .group(author[authorId])
            .order(contentCount.desc)
            .limit(1)

        for row in try db.prepare(queryWithPhoto) {
            return TopAuthorItem(
                authorId: row[author[authorId]],
                authorName: row[author[authorName]],
                authorPhoto: row[author[authorPhoto]],
                shareCount: row[contentCount]
            )
        }

        // Fallback: Get top author without photo requirement
        let queryAny = userShareLog
            .join(soundTable, on: userShareLog[content_id] == soundTable[soundId])
            .join(author, on: soundTable[authorIdOnSounds] == author[authorId])
            .select(author[authorId], author[authorName], author[authorPhoto], contentCount)
            .where(userShareLog[content_type] == 0 || userShareLog[content_type] == 2)
            .filter(dateTime >= firstDay2025 && dateTime < lastDay2025)
            .group(author[authorId])
            .order(contentCount.desc)
            .limit(1)

        for row in try db.prepare(queryAny) {
            return TopAuthorItem(
                authorId: row[author[authorId]],
                authorName: row[author[authorName]],
                authorPhoto: row[author[authorPhoto]],
                shareCount: row[contentCount]
            )
        }

        return nil
    }

    func allDatesInWhichTheUserSharedFor2025Retro() throws -> [Date] {
        guard let firstDay2025 = "2025-01-01T00:00:00.000Z".iso8601withFractionalSeconds,
              let lastDay2025 = "2026-01-01T00:00:00.000Z".iso8601withFractionalSeconds else { return [] }

        var result = [Date]()

        // let content_id = Expression<String>("contentId")
        let content_type = Expression<Int>("contentType")

        let date_time = Expression<Date>("dateTime")

        for row in try db.prepare(
            userShareLog
                .select(userShareLog[date_time])
                .where(userShareLog[content_type] == 0 || userShareLog[content_type] == 2)
                .filter(date_time >= firstDay2025 && date_time < lastDay2025)
        ) {
            result.append(row[date_time])
        }
        return result
    }

    func sharedSoundsCountFor2025Retro() -> Int {
        guard let firstDay2025 = "2025-01-01T00:00:00.000Z".iso8601withFractionalSeconds,
              let lastDay2025 = "2026-01-01T00:00:00.000Z".iso8601withFractionalSeconds else { return 0 }

        let content_id = Expression<String>("contentId")
        let content_type = Expression<Int>("contentType")
        let dateTime = Expression<Date>("dateTime")

        let contentCount = content_id.distinct.count
        let query = userShareLog
            .select(contentCount)
            .where(content_type == 0 || content_type == 2)
            .filter(dateTime >= firstDay2025 && dateTime < lastDay2025)

        do {
            var count = 0
            for row in try db.prepare(query) {
                count = row[contentCount]
            }
            return count
        } catch {
            return 0
        }
    }

    func totalShareCountFor2025Retro() -> Int {
        guard let firstDay2025 = "2025-01-01T00:00:00.000Z".iso8601withFractionalSeconds,
              let lastDay2025 = "2026-01-01T00:00:00.000Z".iso8601withFractionalSeconds else { return 0 }

        let content_id = Expression<String>("contentId")
        let content_type = Expression<Int>("contentType")
        let dateTime = Expression<Date>("dateTime")

        let contentCount = content_id.count
        let query = userShareLog
            .select(contentCount)
            .where(content_type == 0 || content_type == 2)
            .filter(dateTime >= firstDay2025 && dateTime < lastDay2025)

        do {
            var count = 0
            for row in try db.prepare(query) {
                count = row[contentCount]
            }
            return count
        } catch {
            return 0
        }
    }
}

import Foundation
import SQLite

extension LocalDatabase {

    // MARK: - Personal Top Chart

    func getTopSoundsSharedByTheUser(_ limit: Int) throws -> [TopChartItem] {
        guard let firstDay2023 = "2023-01-01T00:00:00.000Z".iso8601withFractionalSeconds else { return [] }

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
                .where(userShareLog[content_type] == 0)
                .filter(dateTime > firstDay2023)
                .group(userShareLog[content_id])
                .order(contentCount.desc)
                .limit(limit)
        ) {
            result.append(
                TopChartItem(
                    id: .empty,
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

    func allDatesInWhichTheUserShared() throws -> [Date] {
        guard let firstDay2023 = "2023-01-01T00:00:00.000Z".iso8601withFractionalSeconds else { return [] }

        var result = [Date]()

        // let content_id = Expression<String>("contentId")
        let content_type = Expression<Int>("contentType")

        let date_time = Expression<Date>("dateTime")

        for row in try db.prepare(
            userShareLog
                .select(userShareLog[date_time])
                .where(userShareLog[content_type] == 0)
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
        guard let firstDay2023 = "2023-01-01T00:00:00.000Z".iso8601withFractionalSeconds else { return 0 }

        let content_id = Expression<String>("contentId")
        let content_type = Expression<Int>("contentType")
        let dateTime = Expression<Date>("dateTime")

        let contentCount = content_id.distinct.count
        let query = userShareLog
            .select(contentCount)
            .where(content_type == 0)
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
        guard let firstDay2023 = "2023-01-01T00:00:00.000Z".iso8601withFractionalSeconds else { return 0 }

        let content_id = Expression<String>("contentId")
        let content_type = Expression<Int>("contentType")
        let dateTime = Expression<Date>("dateTime")

        let contentCount = content_id.count
        let query = userShareLog
            .select(contentCount)
            .where(content_type == 0)
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
}

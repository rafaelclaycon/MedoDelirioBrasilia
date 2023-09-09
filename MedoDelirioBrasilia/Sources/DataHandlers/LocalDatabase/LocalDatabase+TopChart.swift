import Foundation
import SQLite

extension LocalDatabase {

    // MARK: - Personal Top Chart

    func getTop5SoundsSharedByTheUser() throws -> [TopChartItem] {
        var result = [TopChartItem]()
        let content_id = Expression<String>("contentId")
        let content_type = Expression<Int>("contentType")
        
        let contentCount = content_id.count
        for row in try db.prepare(userShareLog
                                      .select(content_id,contentCount)
                                      .where(content_type == 0)
                                      .group(content_id)
                                      .order(contentCount.desc)
                                      .limit(5)) {
            result.append(TopChartItem(id: .empty,
                                       rankNumber: .empty,
                                       contentId: row[content_id],
                                       contentName: .empty,
                                       contentAuthorId: .empty,
                                       contentAuthorName: .empty,
                                       shareCount: row[contentCount]))
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
        for row in try db.prepare(audienceSharingStatistic
                                      .join(soundTable, on: audienceSharingStatistic[content_id] == soundTable[soundId])
                                      .join(author, on: soundTable[authorIdOnSounds] == author[authorId])
                                      .select(audienceSharingStatistic[content_id], soundTable[soundTitle], soundTable[authorId], author[authorName], totalShareCount)
                                      .where(audienceSharingStatistic[content_type] == 0)
                                      .where(audienceSharingStatistic[ranking_type] == timeInterval.rawValue)
                                      .group(audienceSharingStatistic[content_id])
                                      .order(totalShareCount.desc)
                                      .limit(10)) {
            result.append(TopChartItem(id: .empty,
                                       rankNumber: .empty,
                                       contentId: row[audienceSharingStatistic[content_id]],
                                       contentName: row[soundTable[soundTitle]],
                                       contentAuthorId: row[soundTable[authorId]],
                                       contentAuthorName: row[author[authorName]],
                                       shareCount: row[totalShareCount] ?? 0))
        }
        return result
    }

}

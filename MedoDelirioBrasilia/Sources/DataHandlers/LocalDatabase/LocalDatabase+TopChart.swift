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
        
        let totalShareCount = share_count.sum
        for row in try db.prepare(audienceSharingStatistic
                                      .select(content_id,totalShareCount)
                                      .where(content_type == 0)
                                      .where(ranking_type == timeInterval.rawValue)
                                      .group(content_id)
                                      .order(totalShareCount.desc)
                                      .limit(10)) {
            result.append(TopChartItem(id: .empty,
                                       rankNumber: .empty,
                                       contentId: row[content_id],
                                       contentName: .empty,
                                       contentAuthorId: .empty,
                                       contentAuthorName: .empty,
                                       shareCount: row[totalShareCount] ?? 0))
        }
        return result
    }

}

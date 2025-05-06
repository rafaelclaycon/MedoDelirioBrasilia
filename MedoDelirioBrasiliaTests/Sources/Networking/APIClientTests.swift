@testable import MedoDelirio
import Testing
import Foundation

@Suite("APIClient tests") struct APIClientTests {

    @Test func threeDifferentReactions() {
        let today = TopChartReactionDTO(
            position: "1",
            reaction: Reaction.provokingMock.dto,
            description: "hoje"
        )
        let lastWeek = TopChartReactionDTO(
            position: "2",
            reaction: Reaction.classicsMock.dto,
            description: "última semana"
        )
        let allTime = TopChartReactionDTO(
            position: "3",
            reaction: Reaction.greetingsMock.dto,
            description: "todos os tempos"
        )

        let result = APIClient.groupedStats(from: [today, lastWeek, allTime])

        #expect(result.count == 3)
        #expect(result.first?.description == "hoje")
        #expect(result[1].description == "última semana")
        #expect(result[2].description == "todos os tempos")
    }

    @Test func twoEqualOneDifferentReaction() {
        let today = TopChartReactionDTO(
            position: "1",
            reaction: Reaction.provokingMock.dto,
            description: "hoje"
        )
        let lastWeek = TopChartReactionDTO(
            position: "2",
            reaction: Reaction.provokingMock.dto,
            description: "última semana"
        )
        let allTime = TopChartReactionDTO(
            position: "3",
            reaction: Reaction.greetingsMock.dto,
            description: "todos os tempos"
        )

        let result = APIClient.groupedStats(from: [today, lastWeek, allTime])

        #expect(result.count == 2)
        #expect(result.first?.description == "hoje & última semana")
        #expect(result[1].description == "todos os tempos")
    }

    @Test func allEqualReactions() {
        let today = TopChartReactionDTO(
            position: "1",
            reaction: Reaction.provokingMock.dto,
            description: "hoje"
        )
        let lastWeek = TopChartReactionDTO(
            position: "2",
            reaction: Reaction.provokingMock.dto,
            description: "última semana"
        )
        let allTime = TopChartReactionDTO(
            position: "3",
            reaction: Reaction.provokingMock.dto,
            description: "todos os tempos"
        )

        let result = APIClient.groupedStats(from: [today, lastWeek, allTime])

        #expect(result.count == 1)
        #expect(result.first?.description == "hoje, última semana & todos os tempos")
    }

    @Test func eventualAdditionalOne() {
        let today = TopChartReactionDTO(
            position: "1",
            reaction: Reaction.provokingMock.dto,
            description: "hoje"
        )
        let lastWeek = TopChartReactionDTO(
            position: "2",
            reaction: Reaction.provokingMock.dto,
            description: "última semana"
        )
        let lastMonth = TopChartReactionDTO(
            position: "3",
            reaction: Reaction.provokingMock.dto,
            description: "último mês"
        )
        let allTime = TopChartReactionDTO(
            position: "4",
            reaction: Reaction.provokingMock.dto,
            description: "todos os tempos"
        )

        let result = APIClient.groupedStats(from: [today, lastWeek, lastMonth, allTime])

        #expect(result.count == 1)
        #expect(result.first?.description == "hoje, última semana, último mês & todos os tempos")
    }
}

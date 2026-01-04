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

    @Test func filtersOutInvalidReactionsWithNullId() {
        let validReaction = TopChartReactionDTO(
            position: "1",
            reaction: Reaction.provokingMock.dto,
            description: "hoje"
        )
        
        let invalidReaction = TopChartReactionDTO(
            position: "2",
            reaction: ReactionDTO(
                id: nil, // Null ID should be filtered out
                title: "PRESO",
                position: 1,
                image: "https://example.com/image.jpg",
                lastUpdate: "2025-11-22T14:48:45.969Z",
                attributionText: "Test",
                attributionURL: "https://example.com"
            ),
            description: "última semana"
        )

        let result = APIClient.groupedStats(from: [validReaction, invalidReaction])

        #expect(result.count == 1)
        #expect(result.first?.description == "hoje")
    }

    @Test func filtersOutInvalidReactionsWithEmptyTitle() {
        let validReaction = TopChartReactionDTO(
            position: "1",
            reaction: Reaction.provokingMock.dto,
            description: "hoje"
        )
        
        let invalidReaction = TopChartReactionDTO(
            position: "2",
            reaction: ReactionDTO(
                id: "8BF0BBE7-301E-460B-A3D7-1E618E20B9D3",
                title: nil, // Null title should be filtered out
                position: 0,
                image: nil,
                lastUpdate: nil,
                attributionText: nil,
                attributionURL: nil
            ),
            description: "última semana"
        )

        let result = APIClient.groupedStats(from: [validReaction, invalidReaction])

        #expect(result.count == 1)
        #expect(result.first?.description == "hoje")
    }

    @Test func filtersOutInvalidReactionsWithEmptyImageAndLastUpdate() {
        let validReaction = TopChartReactionDTO(
            position: "1",
            reaction: Reaction.provokingMock.dto,
            description: "hoje"
        )
        
        let invalidReaction = TopChartReactionDTO(
            position: "2",
            reaction: ReactionDTO(
                id: "8BF0BBE7-301E-460B-A3D7-1E618E20B9D3",
                title: "PRESO",
                position: 1,
                image: nil, // Null image should be filtered out
                lastUpdate: nil, // Null lastUpdate should be filtered out
                attributionText: "Test",
                attributionURL: "https://example.com"
            ),
            description: "última semana"
        )

        let result = APIClient.groupedStats(from: [validReaction, invalidReaction])

        #expect(result.count == 1)
        #expect(result.first?.description == "hoje")
    }

    @Test func returnsEmptyArrayWhenAllReactionsAreInvalid() {
        let invalidReaction1 = TopChartReactionDTO(
            position: "1",
            reaction: ReactionDTO(
                id: nil,
                title: nil,
                position: 0,
                image: nil,
                lastUpdate: nil,
                attributionText: nil,
                attributionURL: nil
            ),
            description: "hoje"
        )
        
        let invalidReaction2 = TopChartReactionDTO(
            position: "2",
            reaction: ReactionDTO(
                id: "8BF0BBE7-301E-460B-A3D7-1E618E20B9D3",
                title: nil, // Null title makes it invalid
                position: 1,
                image: "https://example.com/image.jpg",
                lastUpdate: "2025-11-22T14:48:45.969Z",
                attributionText: "Test",
                attributionURL: "https://example.com"
            ),
            description: "última semana"
        )

        let result = APIClient.groupedStats(from: [invalidReaction1, invalidReaction2])

        #expect(result.isEmpty)
    }

    @Test func handlesRealWorldScenarioWithMixedValidAndInvalidReactions() {
        // This test simulates the exact scenario from the user's JSON response
        let validReaction1 = TopChartReactionDTO(
            position: "1",
            reaction: ReactionDTO(
                id: "8BF0BBE7-301E-460B-A3D7-1E618E20B9D3",
                title: "PRESO",
                position: 1,
                image: "https://conteudo.imguol.com.br/c/noticias/5a/2025/09/29/o-ex-presidente-jair-bolsonaro-vai-ao-culto-na-catedral-da-bencao-em-taguatinga-1759168036551_v2_900x506.jpg.webp",
                lastUpdate: "2025-11-22T14:48:45.969Z",
                attributionText: "GABRIELA BILÓ/FOLHAPRESS VIA UOL.",
                attributionURL: "https://noticias.uol.com.br/politica/ultimas-noticias/2025/11/22/pedido-de-domiciliar-humanitaria-a-bolsonaro-foi-prejudicado-diz-moraes.htm"
            ),
            description: "hoje"
        )
        
        let invalidReaction = TopChartReactionDTO(
            position: "2",
            reaction: ReactionDTO(
                id: nil, // This is null in the real response
                title: nil,
                position: 0,
                image: nil,
                lastUpdate: nil,
                attributionText: nil,
                attributionURL: nil
            ),
            description: "última semana"
        )
        
        let validReaction2 = TopChartReactionDTO(
            position: "3",
            reaction: ReactionDTO(
                id: "42D32EDA-9059-4CA8-A0F9-E07FFBBD41D3",
                title: "deboche",
                position: 2,
                image: "https://museudememes.com.br/wp-content/uploads/2021/06/fadasdodeboche-4.jpg",
                lastUpdate: "2025-01-25T14:18:16.457Z",
                attributionText: "MUSEU DE MEMES.",
                attributionURL: "https://museudememes.com.br/"
            ),
            description: "todos os tempos"
        )

        let result = APIClient.groupedStats(from: [validReaction1, invalidReaction, validReaction2])

        #expect(result.count == 2)
        #expect(result.first?.description == "hoje")
        #expect(result[1].description == "todos os tempos")
    }
}

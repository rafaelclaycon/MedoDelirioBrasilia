//
//  SearchServiceTests.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 06/05/25.
//

import Testing
@testable import MedoDelirio

struct SearchServiceTests {

    @Test("When an EMPTY string is provided, it is NOT saved")
    func test_emptyStringIsNotSaved() async throws {
        let memory = FakeAppPersistentMemory()
        let service = SearchService(
            contentRepository: FakeContentRepository(),
            authorService: FakeAuthorService(),
            appMemory: memory,
            userFolderRepository: FakeUserFolderRepository()
        )
        service.save(searchString: "")

        #expect(service.recentSearches() == [])
        #expect(memory.recentSearches() == [])
    }

    @Test("When an NON-EMPTY string is provided, it IS saved but only ONCE")
    func test_nonEmptyStringIsSaved() async throws {
        let memory = FakeAppPersistentMemory()
        let service = SearchService(
            contentRepository: FakeContentRepository(),
            authorService: FakeAuthorService(),
            appMemory: memory,
            userFolderRepository: FakeUserFolderRepository()
        )
        service.save(searchString: "Anitt")
        service.save(searchString: "Anitt")
        service.save(searchString: "Anitt")

        #expect(service.recentSearches() == ["Anitt"])
        #expect(memory.recentSearches() == ["Anitt"])
    }

    @Test("When an 3 non-empty strings are provided, they are saved from last to first")
    func test_threeNonEmptyStringsAreSaved() async throws {
        let memory = FakeAppPersistentMemory()
        let service = SearchService(
            contentRepository: FakeContentRepository(),
            authorService: FakeAuthorService(),
            appMemory: memory,
            userFolderRepository: FakeUserFolderRepository()
        )
        service.save(searchString: "Anitt")
        service.save(searchString: "Meme")
        service.save(searchString: "Bolso")

        #expect(service.recentSearches() == ["Bolso", "Meme", "Anitt"])
        #expect(memory.recentSearches() == ["Bolso", "Meme", "Anitt"])
    }

    @Test("Only long versions of a string are saved")
    func test_onlyLongestVersionIsSaved() async throws {
        let memory = FakeAppPersistentMemory()
        let service = SearchService(
            contentRepository: FakeContentRepository(),
            authorService: FakeAuthorService(),
            appMemory: memory,
            userFolderRepository: FakeUserFolderRepository()
        )
        service.save(searchString: "Anitt")
        service.save(searchString: "Meme")
        service.save(searchString: "Jair")

        service.save(searchString: "Jair Bolsonaro")

        service.save(searchString: "Jair Bols")

        #expect(service.recentSearches() == ["Jair Bolsonaro", "Meme", "Anitt"])
        #expect(memory.recentSearches() == ["Jair Bolsonaro", "Meme", "Anitt"])
    }

    @Test("Longer version takes the top spot")
    func test_longerVersionTakesTheTopSpot() async throws {
        let memory = FakeAppPersistentMemory()
        let service = SearchService(
            contentRepository: FakeContentRepository(),
            authorService: FakeAuthorService(),
            appMemory: memory,
            userFolderRepository: FakeUserFolderRepository()
        )
        service.save(searchString: "Meme")
        service.save(searchString: "Jair")
        service.save(searchString: "Anitt")

        service.save(searchString: "Jair Bolsonaro")

        #expect(service.recentSearches() == ["Jair Bolsonaro", "Anitt", "Meme"])
        #expect(memory.recentSearches() == ["Jair Bolsonaro", "Anitt", "Meme"])
    }
}

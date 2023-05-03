@testable import MedoDelirio
import XCTest

class SoundsViewViewModelTests: XCTestCase {
    
    private var sut: SoundsViewViewModel!
    
    override func tearDown() {
        sut = nil
    }
    
    // MARK: - Sound List
    
    /// The sound list order and content can vary by:
    /// - Clean/unclean content;
    /// - Has favorites or not;
    /// - Is showing only favorites or not;
    /// - Sorted by title, author or date added.
    
    func test_reloadList_whenOnlyCleanContentNoFavoritesAndSortedByTitle_shouldDisplay4Sounds() throws {
        sut = SoundsViewViewModel(soundSortOption: SoundSortOption.dateAddedDescending.rawValue,
                                  authorSortOption: AuthorSortOption.nameAscending.rawValue,
                                  currentSoundsListMode: .constant(.regular))
        
        var mockSounds = [Sound]()
        mockSounds.append(Sound(title: "Deu errado", isOffensive: false))
        mockSounds.append(Sound(title: "A gente vai cansando", isOffensive: true))
        mockSounds.append(Sound(title: "Aham, sei", isOffensive: false))
        mockSounds.append(Sound(title: "Cabô cabô cabô", isOffensive: false))
        mockSounds.append(Sound(title: "Bom dia", isOffensive: false))
        
        sut.reloadList(withSounds: mockSounds, andFavorites: nil, allowSensitiveContent: false, favoritesOnly: false, sortedBy: .titleAscending)
        
        XCTAssertEqual(sut.sounds.count, 4)
        XCTAssertEqual(sut.sounds.first?.title, "Aham, sei")
        XCTAssertEqual(sut.sounds.last?.title, "Deu errado")
    }
    
    func test_reloadList_whenAllowsOffensiveContentNoFavoritesAndSortedByTitle_shouldDisplay5Sounds() throws {
        sut = SoundsViewViewModel(soundSortOption: SoundSortOption.dateAddedDescending.rawValue,
                                  authorSortOption: AuthorSortOption.nameAscending.rawValue,
                                  currentSoundsListMode: .constant(.regular))
        
        var mockSounds = [Sound]()
        mockSounds.append(Sound(title: "Deu errado", isOffensive: false))
        mockSounds.append(Sound(title: "A gente vai cansando", isOffensive: true))
        mockSounds.append(Sound(title: "Aham, sei", isOffensive: false))
        mockSounds.append(Sound(title: "Cabô cabô cabô", isOffensive: false))
        mockSounds.append(Sound(title: "Bom dia", isOffensive: false))
        
        sut.reloadList(withSounds: mockSounds, andFavorites: nil, allowSensitiveContent: true, favoritesOnly: false, sortedBy: .titleAscending)
        
        XCTAssertEqual(sut.sounds.count, 5)
        XCTAssertEqual(sut.sounds.first?.title, "A gente vai cansando")
        XCTAssertEqual(sut.sounds.last?.title, "Deu errado")
    }
    
    func test_reloadList_whenAllowsOffensiveContent_favoritesOnly_andSortedByTitle_shouldDisplay1Sound() throws {
        sut = SoundsViewViewModel(soundSortOption: SoundSortOption.dateAddedDescending.rawValue,
                                  authorSortOption: AuthorSortOption.nameAscending.rawValue,
                                  currentSoundsListMode: .constant(.regular))
        
        var mockSounds = [Sound]()
        mockSounds.append(Sound(title: "Deu errado", isOffensive: false))
        mockSounds.append(Sound(title: "A gente vai cansando", isOffensive: true))
        mockSounds.append(Sound(title: "Aham, sei", isOffensive: false))
        mockSounds.append(Sound(id: "ABC", title: "Cabô cabô cabô", isOffensive: false))
        mockSounds.append(Sound(title: "Bom dia", isOffensive: false))
        
        var mockFavorites = [Favorite]()
        mockFavorites.append(Favorite(contentId: "ABC"))
        
        sut.reloadList(withSounds: mockSounds, andFavorites: mockFavorites, allowSensitiveContent: true, favoritesOnly: true, sortedBy: .titleAscending)
        
        XCTAssertEqual(sut.sounds.count, 1)
        XCTAssertEqual(sut.sounds.first?.title, "Cabô cabô cabô")
    }
    
    func test_reloadList_whenAllowsOffensiveContent_favoritesOnly_andSortedByTitle_butNoFavoritesExist_shouldDisplayNoSounds() throws {
        sut = SoundsViewViewModel(soundSortOption: SoundSortOption.dateAddedDescending.rawValue,
                                  authorSortOption: AuthorSortOption.nameAscending.rawValue,
                                  currentSoundsListMode: .constant(.regular))
        
        var mockSounds = [Sound]()
        mockSounds.append(Sound(title: "Deu errado", isOffensive: false))
        mockSounds.append(Sound(title: "A gente vai cansando", isOffensive: true))
        mockSounds.append(Sound(title: "Aham, sei", isOffensive: false))
        mockSounds.append(Sound(id: "ABC", title: "Cabô cabô cabô", isOffensive: false))
        mockSounds.append(Sound(title: "Bom dia", isOffensive: false))
        
        let mockFavorites = [Favorite]()
        
        sut.reloadList(withSounds: mockSounds, andFavorites: mockFavorites, allowSensitiveContent: true, favoritesOnly: true, sortedBy: .titleAscending)
        
        XCTAssertEqual(sut.sounds.count, 0)
    }
}

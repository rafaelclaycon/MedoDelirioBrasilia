import Foundation
import SQLite
import SQLiteMigrationManager

internal protocol LocalDatabaseProtocol {

    // Sound
    func insert(sound newSound: Sound) throws
    func update(sound updatedSound: Sound) throws
    func delete(soundId: String) throws
    func setIsFromServer(to value: Bool, on soundId: String) throws

    // Author
    func insert(author newAuthor: Author) throws
    func update(author updatedAuthor: Author) throws
    func delete(authorId: String) throws

    // UserFolder
    func contentExistsInsideUserFolder(withId folderId: String, contentId: String) throws -> Bool
    
    // Song
    func insert(song newSong: Song) throws
    func update(song updatedSong: Song) throws
    func delete(songId: String) throws
    
    // Music Genre
    func insert(genre newGenre: MusicGenre) throws
    func update(genre updatedGenre: MusicGenre) throws
    func delete(genreId: String) throws

    // UpdateEvent
    func insert(updateEvent newUpdateEvent: UpdateEvent) throws
    func markAsSucceeded(updateEventId: UUID) throws
    func unsuccessfulUpdates() throws -> [UpdateEvent]

    // SyncLog
    func insert(syncLog newSyncLog: SyncLog)
}

class LocalDatabase: LocalDatabaseProtocol {

    var db: Connection
    var migrationManager: SQLiteMigrationManager
    
    var favorite = Table("favorite")
    var userShareLog = Table("userShareLog")
    var audienceSharingStatistic = Table("audienceSharingStatistic")
    var networkCallLog = Table("networkCallLog")
    var userFolder = Table("userFolder")
    var userFolderContent = Table("userFolderContent")
    var sound = Table("sound")
    var author = Table("author")
    var updateEventTable = Table("updateEvent")
    var syncLogTable = Table("syncLog")
    let songTable = Table("song")
    var musicGenreTable = Table("musicGenre")

    static let shared = LocalDatabase()
    
    // MARK: - Setup
    
    init() {
        do {
            db = try Connection(LocalDatabase.databaseFilepath())
        } catch {
            fatalError(error.localizedDescription)
        }
        
        self.migrationManager = SQLiteMigrationManager(db: self.db, migrations: LocalDatabase.migrations())
    }
    
    func migrateIfNeeded() throws {
        if !migrationManager.hasMigrationsTable() {
            try migrationManager.createMigrationsTable()
        }

        if migrationManager.needsMigration() {
            try migrationManager.migrateDatabase()
        }
    }

}

extension LocalDatabase {

    static func databaseFilepath() -> String {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        return "\(path)/medo_db.sqlite3"
    }

    static func migrations() -> [Migration] {
        return [
            InitialMigration(),
            AddNetworkCallLogTable(),
            AddUserFolderTables(),
            RemoveFavoriteLogTable(),
            AddAudienceSharingStatisticTable(),
            AddRankingTypeToAudienceSharingStatisticTable(),
            AddDateAndVersionToUserFolderTables(),
            AddSyncTables(),
            AddSongAndMusicGenreTables()
        ]
    }

    var needsMigration: Bool {
        return migrationManager.needsMigration()
    }
}

extension LocalDatabase: CustomStringConvertible {

    var description: String {
        return "Database:\n" +
        "url: \(LocalDatabase.databaseFilepath())\n" +
        "migration state:\n" +
        "  hasMigrationsTable() \(migrationManager.hasMigrationsTable())\n" +
        "  currentVersion()     \(migrationManager.currentVersion())\n" +
        "  originVersion()      \(migrationManager.originVersion())\n" +
        "  appliedVersions()    \(migrationManager.appliedVersions())\n" +
        "  pendingMigrations()  \(migrationManager.pendingMigrations())\n" +
        "  needsMigration()     \(migrationManager.needsMigration())"
    }

}

enum LocalDatabaseError: Error {

    case favoriteNotFound
    case folderNotFound
    case folderContentNotFound
    case internalError
    case authorNotFound
    case songNotFound
    case musicGenreNotFound
}

extension LocalDatabaseError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .favoriteNotFound:
            return NSLocalizedString("O Favorito solicitado não foi encontrado no banco de dados.", comment: "Favorito Não Encontrado")
        case .folderNotFound:
            return NSLocalizedString("A Pasta solicitada não foi encontrada no banco de dados.", comment: "Pasta Não Encontrada")
        case .folderContentNotFound:
            return NSLocalizedString("O Conteúdo de Pasta solicitado não foi encontrado no banco de dados.", comment: "Conteúdo de Pasta Não Encontrado")
        case .internalError:
            return NSLocalizedString("Ocorreu um erro interno.", comment: "Erro Interno")
        case .authorNotFound:
            return NSLocalizedString("O Autor solicitado não foi encontrado no banco de dados.", comment: "Autor Não Encontrado")
        case .songNotFound:
            return NSLocalizedString("A Música solicitada não foi encontrada no bando de dados.", comment: "")
        case .musicGenreNotFound:
            return NSLocalizedString("O Gênero Musical solicitado não foi encontrado no banco de dados.", comment: "")
        }
    }
}

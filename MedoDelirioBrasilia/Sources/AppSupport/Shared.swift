import Foundation

struct Shared {

    struct ActivityTypes {
        
        static let playAndShareSounds = "com.rafaelschmitt.MedoDelirioBrasilia.PlayAndShareSounds"
        static let viewCollections = "com.rafaelschmitt.MedoDelirioBrasilia.ViewCollections"
        static let playAndShareSongs = "com.rafaelschmitt.MedoDelirioBrasilia.PlayAndShareSongs"
        static let viewLast24HoursTopChart = "com.rafaelschmitt.MedoDelirioBrasilia.ViewLast24HoursTopChart"
        static let viewLastWeekTopChart = "com.rafaelschmitt.MedoDelirioBrasilia.ViewLastWeekTopChart"
        static let viewLastMonthTopChart = "com.rafaelschmitt.MedoDelirioBrasilia.ViewLastMonthTopChart"
        static let viewAllTimeTopChart = "com.rafaelschmitt.MedoDelirioBrasilia.ViewAllTimeTopChart"
        
    }
    
    static let addToFolderButtonText = "Adicionar a Pasta"
    static let shareSoundButtonText = "Compartilhar Som"
    static let shareSongButtonText = "Compartilhar Música"
    static let shareAsVideoButtonText = "Compartilhar como Vídeo"
    
    static let contentFilterMessageForSoundsiPhone = "Alguns sons não estão sendo exibidos pois a opção Exibir Conteúdo Explícito está desabilitada. Você pode mudar isso nas Configurações (ícone de engrenagem aqui no topo esquerdo da tela)."
    static let contentFilterMessageForSoundsiPadMac = "Alguns sons não estão sendo exibidos pois a opção Exibir Conteúdo Explícito está desabilitada. Você pode mudar isso na tela de Configurações (ícone de engrenagem no topo da barra lateral do app)."
    static let contentFilterMessageForSongsiPhone = "Algumas músicas não estão sendo exibidas pois a opção Exibir Conteúdo Explícito está desabilitada. Você pode mudar isso nas Configurações (ícone de engrenagem no topo da aba Sons do app)."
    static let contentFilterMessageForSongsiPadMac = "Algumas músicas não estão sendo exibidas pois a opção Exibir Conteúdo Explícito está desabilitada. Você pode mudar isso na tela de Configurações (ícone de engrenagem no topo da barra lateral do app)."
    
    static let soundNotFoundAlertTitle = "Som Indisponível"
    static let soundNotFoundAlertMessage = "Devido a um problema técnico, o som que você quer acessar não está disponível."
    static let soundSharedSuccessfullyMessage = "Som compartilhado com sucesso."
    static let songSharedSuccessfullyMessage = "Música compartilhada com sucesso."
    static let videoSharedSuccessfullyMessage = "Vídeo compartilhado com sucesso."
    
    static let unknownAuthor = "Desconhecido"
    
    struct Songs {
        
        static let songNotFoundAlertTitle = "Música Indisponível"
        static let songNotFoundAlertMessage = "Devido a um problema técnico, a música que você quer acessar não está disponível."
        
    }
    
    // E-mail
    
    static let pickAMailApp = "Escolha um app de e-mail"
    static let issueSuggestionEmailSubject = "Problema/sugestão no app iOS \(Versioneer.appVersion) Build \(Versioneer.buildVersionNumber)"
    static let issueSuggestionEmailBody = "Para um problema, inclua passos para reproduzir e prints se possível."
    static let suggestOtherAuthorNameEmailSubject = "Sugestão de Outro Nome de Autor Para %@"
    static let suggestOtherAuthorNameEmailBody = "Nome de autor antigo: %@\nNovo nome de autor: \n\nID do conteúdo: %@ (para uso interno)"
    
    struct Email {
        
        static let suggestSongChangeSubject = "Sugestão de Alteração Para a Música '%@'"
        static let suggestSongChangeBody = "\n\n\nID do conteúdo: %@ (para uso interno)"
        
    }
    
    struct ShareAsVideo {
        
        static let generatingVideoShortMessage = "Gerando vídeo..."
        static let generatingVideoLongMessage = "Gerando vídeo...\nIsso pode demorar um pouco."
        static let videoSavedSucessfully = "Vídeo salvo com sucesso."
        static let videoSavedSucessfullyMac = "Vídeo salvo com sucesso no app Fotos."
        
    }
    
    struct Trends {
        
        static let last24Hours = "Últimas 24 horas"
        static let lastWeek = "Última semana"
        static let lastMonth = "Último mês"
        static let allTime = "Todos os tempos"

    }
    
    struct Folders {
        
        static let defaultFolderColor = "pastelPurple"
        
    }
    
    struct ScreenNames {
        
        static let soundsView = "SoundsView"
        static let authorsView = "AuthorsView"
        static let authorDetailView = "AuthorDetailView"
        
    }

}

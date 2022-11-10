import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

}

struct SimpleEntry: TimelineEntry {

    let date: Date

}

struct MedoWidgetEntryView : View {

    @Environment(\.widgetFamily) var widgetFamily
    
    var entry: Provider.Entry
    
    var body: some View {
        switch widgetFamily {
            
            
// Circular widget under construction
//        case .accessoryCircular:
//            Image("figure.walk.departure")
//            Gauge(value: 0.92) {
//                Text("GOV")
//            } currentValueLabel: {
//                VStack(alignment: .center) {
//                    Text("131d")
//                        .font(.system(size: 12))
//                    
//                }
//            }
//            .gaugeStyle(.accessoryCircular)
            
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text(getDaysUntilDateShort(endOfCurrentMandateDate(), considering: .daysToJaIr))
                    .font(.headline)
                
                Text("Fim do Governo")
                    .textCase(.uppercase)
                    //.font(.system(size: 13))
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
        case .accessoryInline:
            HStack {
                Text(getPhrase(getRandomPhraseType()))
            }
            // 🏃‍♂️ 52 dias para já ir
            // ⭐️ O barba vem em 52 dias
            // 👋 "Tchau, Jair" em 52 dias
            // 🍆 Jambrolhando em 52 dias
            
        default:
            Text("Não implementado")
        }
    }
    
    /*private func mockDate() -> Date {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: "2022-10-03T00:00:00-0300")!
    }*/
    
    private func getRandomPhraseType() -> FunnyPhrase {
        return FunnyPhrase(rawValue: Int.random(in: 0..<4))!
    }
    
    private func getPhrase(_ type: FunnyPhrase) -> String {
        switch type {
        case .daysToJaIr:
            return "🏃‍♂️  \(getDaysUntilDateShort(endOfCurrentMandateDate(), considering: type)) para já ir"
        case .theBeardedOneIsComing:
            return "⭐️  O barba \(getDaysUntilDateShort(endOfCurrentMandateDate(), considering: type))"
        case .byeByeJair:
            return "👋  Tchau \(getDaysUntilDateShort(endOfCurrentMandateDate(), considering: type))"
        case .veryPhallicReference:
            return "·  Jambro👌 \(getDaysUntilDateShort(endOfCurrentMandateDate(), considering: type))"
        }
    }
    
    private func endOfCurrentMandateDate() -> Date {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: "2023-01-01T00:00:00-0300")!
    }
    
    private func getDaysUntilDateShort(_ date: Date, considering funnyPhraseType: FunnyPhrase) -> String {
        let calendar = Calendar.current
        
        let date1 = calendar.startOfDay(for: Date.now)
        let date2 = calendar.startOfDay(for: date)
        
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        
        if let days = components.day {
            // Já passou
            if days < 0 {
                switch funnyPhraseType {
                case .daysToJaIr:
                    return "Foi"
                case .theBeardedOneIsComing:
                    return "já tá aí"
                case .byeByeJair:
                    return "querido"
                case .veryPhallicReference:
                    return "chegou"
                }
                
            // Hoje
            } else if days == 0 {
                switch funnyPhraseType {
                case .daysToJaIr:
                    return "É hoje"
                case .theBeardedOneIsComing:
                    return "vem hoje!"
                case .byeByeJair:
                    return "hoje!"
                case .veryPhallicReference:
                    return "vem hoje!"
                }
                
            // Amanhã
            } else if days == 1 {
                switch funnyPhraseType {
                case .daysToJaIr:
                    return "Amanhã"
                case .theBeardedOneIsComing:
                    return "chega amanhã"
                case .byeByeJair:
                    return "querido amanhã"
                case .veryPhallicReference:
                    return "vem amanhã"
                }
                
            // Mais dias
            } else {
                switch funnyPhraseType {
                case .daysToJaIr:
                    return "\(days) dias"
                case .theBeardedOneIsComing, .veryPhallicReference:
                    return "em \(days) dias"
                case .byeByeJair:
                    return " em \(days) dias"
                }
            }
        } else {
            return "Indefinido"
        }
    }

}

@main
struct MedoWidget: Widget {

    let kind: String = "MedoWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MedoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Contagem Regressiva")
        .description("Acompanhe a aproximação de datas importantes.")
        .supportedFamilies([.accessoryInline, .accessoryRectangular])
    }

}

struct MedoWidget_Previews: PreviewProvider {

    static var previews: some View {
        MedoWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .accessoryInline))
            .previewDisplayName("Inline")
        
//        MedoWidgetEntryView(entry: SimpleEntry(date: Date()))
//            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
//            .previewDisplayName("Circular")
        
        MedoWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            .previewDisplayName("Rectangular")
    }

}

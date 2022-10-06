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
    
    var displayLulaWon: Bool {
        return UserDefaults(suiteName: "group.com.rafaelschmitt.MedoDelirioBrasilia")!.bool(forKey: "displayLulaWon")
    }
    
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
            VStack(alignment: .leading, spacing: -1) {
                if displayLulaWon {
                    Text("É Lula!")
                        .bold()
                        .font(.system(size: 14))
                    
                    Text("É Lula, porrrraaaa")
                        .textCase(.uppercase)
                        .font(.system(size: 12))
                        .fontWeight(.medium)
                } else {
                    Text(getDaysUntilDateShort(secondTurnDate()))
                        .bold()
                        .font(.system(size: 14))
                    
                    Text("Segundo Turno")
                        .textCase(.uppercase)
                        .font(.system(size: 12))
                        .fontWeight(.medium)
                }
                
                Text(getDaysUntilDateShort(endOfCurrentMandateDate()))
                    .bold()
                    .font(.system(size: 14))
                
                Text("Fim do Governo")
                    .textCase(.uppercase)
                    .font(.system(size: 12))
                    .fontWeight(.medium)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
        case .accessoryInline:
            if displayLulaWon {
                HStack {
                    Image(systemName: "medal.fill")
                    Text(" É Lula!!!!")
                }
            } else {
                HStack {
                    Image(systemName: "calendar")
                    Text(getDaysUntilDateLong(secondTurnDate(), isFirstTurn: false))
                }
            }
            
        default:
            Text("Não implementado")
        }
    }
    
    /*private func mockDate() -> Date {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: "2022-10-03T00:00:00-0300")!
    }*/
    
    private func secondTurnDate() -> Date {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: "2022-10-30T00:00:00-0300")!
    }
    
    private func endOfCurrentMandateDate() -> Date {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: "2023-01-01T00:00:00-0300")!
    }
    
    private func getDaysUntilDateShort(_ date: Date) -> String {
        let calendar = Calendar.current
        
        let date1 = calendar.startOfDay(for: Date.now)
        let date2 = calendar.startOfDay(for: date)
        
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        
        if let days = components.day {
            if days < 0 {
                return "Já passou"
            } else if days == 0 {
                return "Hoje"
            } else if days == 1 {
                return "Amanhã"
            } else {
                return "\(days) dias"
            }
        } else {
            return "Indefinido"
        }
    }
    
    private func getDaysUntilDateLong(_ date: Date, isFirstTurn: Bool) -> String {
        let calendar = Calendar.current
        
        let date1 = calendar.startOfDay(for: Date.now)
        let date2 = calendar.startOfDay(for: date)
        
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        
        let turnNumber = isFirstTurn ? "1" : "2"
        
        if let days = components.day {
            if days < 0 {
                return "O \(turnNumber)º turno já passou"
            } else if days == 0 {
                return "O \(turnNumber)º turno é hoje"
            } else if days == 1 {
                return "O \(turnNumber)º turno é amanhã!"
            } else {
                return "\(days) dias até o \(turnNumber)º turno"
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

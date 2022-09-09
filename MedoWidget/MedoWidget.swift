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
            // case .systemSmall:
            
            //  case .systemMedium:
            
            //  case .systemLarge:
            
            //  case .systemExtraLarge:
            
            //  case .accessoryCorner:
            
        case .accessoryCircular:
            Image("figure.walk.departure")
            Gauge(value: 0.92) {
                Text("GOV")
            } currentValueLabel: {
                VStack(alignment: .center) {
                    Text("131d")
                        .font(.system(size: 12))
                    
                }
            }
            .gaugeStyle(.accessoryCircular)
            
        case .accessoryRectangular:
            VStack(alignment: .leading) {
                Text("40 dias")
                    .bold()
                    .font(.system(size: 14))
                
                Text("Primeiro Turno")
                    .textCase(.uppercase)
                    .font(.system(size: 12))
                    .fontWeight(.medium)
                
                
                Text("131 dias")
                    .bold()
                    .font(.system(size: 14))
                
                Text("Fim do Governo")
                    .textCase(.uppercase)
                    .font(.system(size: 12))
                    .fontWeight(.medium)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
        case .accessoryInline:
            HStack {
                Image(systemName: "calendar")
                Text("40 dias para o 1º turno")
            }
            
        default:
            Text("Not implemented")
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
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.accessoryInline, .accessoryCircular, .accessoryRectangular])
    }
    
}

struct MedoWidget_Previews: PreviewProvider {

    static var previews: some View {
        MedoWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .accessoryInline))
            .previewDisplayName("Inline")
        
        MedoWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
            .previewDisplayName("Circular")
        
        MedoWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            .previewDisplayName("Rectangular")
    }

}

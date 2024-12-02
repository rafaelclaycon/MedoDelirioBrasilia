//
//  MedoDelirioSyncWidgetLiveActivity.swift
//  MedoDelirioSyncWidget
//
//  Created by Rafael Schmitt on 02/12/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

public struct SyncActivityAttributes: ActivityAttributes {

    public struct ContentState: Codable, Hashable {
//        var progress: Double
//        var status: String
        public var emoji: String

        public init(emoji: String) {
            self.emoji = emoji
        }
    }

    public var title: String

    public init(title: String) {
        self.title = title
    }
}

struct MedoDelirioSyncWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SyncActivityAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension SyncActivityAttributes {

    fileprivate static var preview: SyncActivityAttributes {
        SyncActivityAttributes(title: "World")
    }
}

extension SyncActivityAttributes.ContentState {

    fileprivate static var smiley: SyncActivityAttributes.ContentState {
        SyncActivityAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: SyncActivityAttributes.ContentState {
         SyncActivityAttributes.ContentState(emoji: "🤩")
     }
}

//#Preview("Notification", as: .content, using: SyncActivityAttributes.preview) {
//   MedoDelirioSyncWidgetLiveActivity()
//} contentStates: {
//    SyncActivityAttributes.ContentState.smiley
//    SyncActivityAttributes.ContentState.starEyes
//}

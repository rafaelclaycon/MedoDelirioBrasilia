//
//  MedoDelirioLiveActivity.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 05/12/23.
//

import SwiftUI
import WidgetKit

struct MedoDelirioLiveActivity: Widget {

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SyncAttributes.self) { context in
            // Lock screen/banner UI goes here
            LiveActivityView(state: context.state)
        } dynamicIsland: { context in
            DynamicIsland {
                expandedContent()
            } compactLeading: {
                Image(systemName: "figure.run")
            } compactTrailing: {
                Image(systemName: "figure.run")
            } minimal: {
                Image(systemName: "figure.run")
            }

        }
    }

    @DynamicIslandExpandedContentBuilder
    private func expandedContent() -> DynamicIslandExpandedContent<some View> {
        DynamicIslandExpandedRegion(.leading) {
            LiveActivityAvatarView(hero: hero)
        }

        DynamicIslandExpandedRegion(.trailing) {
            StatsView(
                hero: hero,
                isStale: isStale
            )
        }

        DynamicIslandExpandedRegion(.bottom) {
            HealthBar(currentHealthLevel: contentState.currentHealthLevel)

            EventDescriptionView(
                hero: hero,
                contentState: contentState
            )
        }
    }
}

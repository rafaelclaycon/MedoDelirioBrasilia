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

        var status: String
        var current: Int
        var total: Int

        public init(
            status: String,
            current: Int,
            total: Int
        ) {
            self.status = status
            self.current = current
            self.total = total
        }
    }

    public var title: String

    public init(title: String) {
        self.title = title
    }
}

struct MedoDelirioSyncWidgetLiveActivity: Widget {

    private let errorSymbol = "☹️"
    private let errorTitle = "Problema na Atualização"
    private let errorMessage = "Peço desculpas, digo \"errei\"."

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SyncActivityAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                switch context.state.status {
                case "updating":
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Atualizando Conteúdos...")
                            .bold()
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.white)

                        Text("Novidades estão a caminho.")
                            .font(.callout)
                            .foregroundStyle(.white)
                            .opacity(0.9)

                        ProgressView(
                            "\(context.state.current)/\(context.state.total)",
                            value: Double(context.state.current),
                            total: Double(context.state.total)
                        )
                        .foregroundStyle(.white)
                        .bold()
                        .padding(.top, 8)
                        .padding(.bottom, 10)
                    }
                    .overlay(alignment: .topTrailing) {
                        Image("logoYellow")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36)
                    }
                    .padding(.all, 20)

                case "updateError":
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(errorTitle) \(errorSymbol)")
                            .bold()
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.white)

                        Text(errorMessage)
                            .font(.callout)
                            .foregroundStyle(.white)
                            .opacity(0.9)

                        ProgressView(
                            "\(context.state.current)/\(context.state.total)",
                            value: Double(context.state.current),
                            total: Double(context.state.total)
                        )
                        .foregroundStyle(.white)
                        .bold()
                        .padding(.top, 8)
                        .padding(.bottom, 10)
                        .opacity(0)
                    }
                    .overlay(alignment: .topTrailing) {
                        Image("logoYellow")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36)
                    }
                    .padding(.all, 20)

                default:
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 10) {
                            Text("Conteúdos Atualizados")
                                .bold()
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(.white)

                            Image(systemName: "checkmark")
                                .bold()
                                .foregroundStyle(.white)

                            Spacer()
                        }

                        Text("Todo relaxado, gostosão, tranquilo.")
                            .font(.callout)
                            .foregroundStyle(.white)
                            .opacity(0.9)

                        ProgressView(
                            "\(context.state.current)/\(context.state.total)",
                            value: Double(context.state.current),
                            total: Double(context.state.total)
                        )
                        .foregroundStyle(.white)
                        .bold()
                        .padding(.top, 8)
                        .padding(.bottom, 10)
                    }
                    .overlay(alignment: .topTrailing) {
                        Image("logoYellow")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36)
                    }
                    .padding(.all, 20)
                }
            }
            .background {
                Color.green
            }
            .activityBackgroundTint(Color.green)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here. Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    switch context.state.status {
                    case "updating":
                        ProgressView(value: Double(context.state.current), total: Double(context.state.total))
                            .progressViewStyle(GaugeProgressStyle())
                            .frame(width: 18, height: 18)
                            .padding(.all, 5)

                    case "updateError":
                        Text("☹️")
                            .padding(.horizontal, 5)

                    default:
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.green)
                            .padding(.horizontal, 5)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Image("logoYellow")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    switch context.state.status {
                    case "updating":
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Atualizando Conteúdos...")
                                    .bold()
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(.white)

                                Text("Novidades estão a caminho.")
                                    .font(.callout)
                                    .foregroundStyle(.white)
                                    .opacity(0.9)
                            }

                            Spacer()
                        }
                        .padding(.all, 10)

                    case "updateError":
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(errorTitle)
                                    .bold()
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(.white)

                                Text(errorMessage)
                                    .font(.callout)
                                    .foregroundStyle(.white)
                                    .opacity(0.9)
                            }

                            Spacer()
                        }
                        .padding(.all, 10)

                    default:
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 10) {
                                Text("Conteúdos Atualizados")
                                    .bold()
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(.white)

//                                Image(systemName: "checkmark")
//                                    .bold()
//                                    .foregroundStyle(.white)

                                Spacer()
                            }

                            Text("Todo relaxado, gostosão, tranquilo.")
                                .font(.callout)
                                .foregroundStyle(.white)
                                .opacity(0.9)
                        }
                        .padding(.all, 10)
                    }
                }
            } compactLeading: {
                switch context.state.status {
                case "updating":
                    ProgressView(value: Double(context.state.current), total: Double(context.state.total))
                        .progressViewStyle(GaugeProgressStyle())
                        .frame(width: 18, height: 18)
                        .padding(.horizontal, 5)
                case "updateError":
                    Text("☹️")
                        .padding(.horizontal, 5)

                default:
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.green)
                        .padding(.horizontal, 5)
                }
            } compactTrailing: {
                Image(systemName: "icloud.and.arrow.down")
                    .bold()

//                Image("logo")
//                    .resizable()
//                    .scaledToFit()
//                    .foregroundStyle(.green)
//                    .frame(width: 18)
            } minimal: {
                switch context.state.status {
                case "updating":
                    Image(systemName: "icloud.and.arrow.down")
                        .bold()

                case "updateError":
                    Text("☹️")

                default:
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.green)
                        .padding(.horizontal, 5)
                }
            }
            .widgetURL(URL(string: "medodelirio://"))
            .keylineTint(Color.green)
        }
    }
}

extension SyncActivityAttributes {

    fileprivate static var preview: SyncActivityAttributes {
        SyncActivityAttributes(title: "Sync")
    }
}

extension SyncActivityAttributes.ContentState {

    fileprivate static var updating: SyncActivityAttributes.ContentState {
        SyncActivityAttributes.ContentState(status: "updating", current: 2, total: 10)
     }
     
     fileprivate static var aboutToFinish: SyncActivityAttributes.ContentState {
         SyncActivityAttributes.ContentState(status: "updating", current: 10, total: 10)
     }

    fileprivate static var done: SyncActivityAttributes.ContentState {
        SyncActivityAttributes.ContentState(status: "done", current: 10, total: 10)
    }

    fileprivate static var updateError: SyncActivityAttributes.ContentState {
        SyncActivityAttributes.ContentState(status: "updateError", current: 10, total: 10)
    }
}

#Preview("Notification", as: .content, using: SyncActivityAttributes.preview) {
   MedoDelirioSyncWidgetLiveActivity()
} contentStates: {
    SyncActivityAttributes.ContentState.updating
    SyncActivityAttributes.ContentState.aboutToFinish
    SyncActivityAttributes.ContentState.done
    SyncActivityAttributes.ContentState.updateError
}

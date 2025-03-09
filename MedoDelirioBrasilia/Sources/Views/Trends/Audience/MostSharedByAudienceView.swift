//
//  MostSharedByAudienceView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 11/10/22.
//

import SwiftUI

struct MostSharedByAudienceView: View {

    @ObservedObject var viewModel: ViewModel
    @Binding var tabSelection: PhoneTab
    @Binding var activePadScreen: PadScreen?
    @EnvironmentObject var trendsHelper: TrendsHelper
    @Environment(\.scenePhase) var scenePhase

    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 30) {
            TitledRankingView(
                title: "Sons Mais Compartilhados Pela Audiência",
                state: viewModel.soundsState,
                timeIntervalOption: $viewModel.soundsTimeInterval,
                lastUpdatedDate: .now, // Change
                navigateToAction: { soundId in
                    navigateTo(sound: soundId)
                }
            )
            .onChange(of: viewModel.soundsTimeInterval) { newInterval in
                Task {
                    await viewModel.onSoundsSelectedTimeIntervalChanged(newTimeInterval: newInterval)
                }
            }

            TitledRankingView(
                title: "Músicas Mais Compartilhadas Pela Audiência",
                state: viewModel.songsState,
                timeIntervalOption: $viewModel.songsTimeInterval,
                lastUpdatedDate: .now,
                navigateToAction: { _ in
                    //navigateTo(sound: soundId)
                }
            )
            .onChange(of: viewModel.songsTimeInterval) { newInterval in
                Task {
                    await viewModel.onSongsSelectedTimeIntervalChanged(newTimeInterval: newInterval)
                }
            }

            ReactionsRankingView(
                title: "Reações Mais Populares",
                state: viewModel.reactionsState,
                lastUpdatedDate: viewModel.reactionsLastCheckDate,
                navigateToAction: { reactionId in
                    navigateTo(reaction: reactionId)
                },
                reloadAction: {
                    Task {
                        await viewModel.onReloadPopularReactionsSelected()
                    }
                }
            )

            Text("Os dados se referem apenas à audiência dos apps iOS/iPadOS/Mac.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
        }
        .padding(.bottom, 10)
        .onReceive(timer) { input in
            viewModel.updateLastUpdatedAtText()
        }
        .onAppear {
            Task {
                await viewModel.onViewAppeared()
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
        .onChange(of: scenePhase) { newPhase in
            Task {
                await viewModel.onScenePhaseChanged(isNewPhaseActive: newPhase == .active)
            }
        }
    }

    private func navigateTo(sound soundId: String) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            tabSelection = .sounds
        } else {
            activePadScreen = .allSounds
        }
        trendsHelper.soundIdToGoTo = soundId
    }

    private func navigateTo(reaction reactionId: String) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            tabSelection = .reactions
        } else {
            activePadScreen = .reactions
        }
        //trendsHelper.soundIdToGoTo = soundId
    }
}

// MARK: - Subviews

extension MostSharedByAudienceView {

    struct TitledRankingView: View {

        // MARK: - External Dependencies

        let title: String
        let state: LoadingState<[TopChartItem]>
        @Binding var timeIntervalOption: TrendsTimeInterval
        let lastUpdatedDate: Date
        let navigateToAction: (String) -> Void

        // MARK: - Private Properties

        private var lastUpdatedAtText: String {
            if lastUpdatedDate == Date(timeIntervalSince1970: 0) {
                return "Última consulta: indisponível"
            } else {
                return "Última consulta: \(lastUpdatedDate.asRelativeDateTime)"
            }
            //return "Última consulta: agora mesmo"
        }

        private let columns = [GridItem(.flexible())]
        private let columnsMac = [GridItem(.fixed(500))]

        private var dropDownText: String {
            switch timeIntervalOption {
            case .last24Hours:
                Shared.Trends.last24Hours
            case .last3Days:
                Shared.Trends.last3Days
            case .lastWeek:
                Shared.Trends.lastWeek
            case .lastMonth:
                Shared.Trends.lastMonth
            case .year2024:
                Shared.Trends.year2024
            case .year2023:
                Shared.Trends.year2023
            case .year2022:
                Shared.Trends.year2022
            case .allTime:
                Shared.Trends.allTime
            }
        }

        // MARK: - View Body

        var body: some View {
            VStack {
                HStack {
                    Text(title)
                        .font(.title2)
                    Spacer()
                }
                .padding(.horizontal)

                HStack(spacing: 20) {
                    timeIntervalSelector()

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 1)
                .padding(.bottom)

                switch state {
                case .loading:
                    LoadingView()

                case .loaded(let items):
                    if items.isEmpty {
                        NoDataToDisplayView()
                    } else {
                        LazyVGrid(columns: UIDevice.isMac ? columnsMac : columns, spacing: .zero) {
                            ForEach(items) { item in
                                TopChartRow(item: item)
                                    .onTapGesture {
                                        navigateToAction(item.contentId)
                                    }
                                    .contextMenu {
                                        if UIDevice.isiPhone {
                                            Button {
                                                navigateToAction(item.contentId)
                                            } label: {
                                                Label("Ir para Som", systemImage: "arrow.uturn.backward")
                                            }
                                        }
                                    }
                            }
                        }
                        .padding(.top, -10)

                        Text(lastUpdatedAtText)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.bottom)
                    }

                case .error(let errorMessage):
                    Text(errorMessage)
                }
            }
        }

        // MARK: - Subviews

        @ViewBuilder func timeIntervalSelector() -> some View {
            Menu {
                Picker("Período", selection: $timeIntervalOption) {
                    Text(Shared.Trends.last24Hours).tag(TrendsTimeInterval.last24Hours)
                    Text(Shared.Trends.last3Days).tag(TrendsTimeInterval.last3Days)
                    Text(Shared.Trends.lastWeek).tag(TrendsTimeInterval.lastWeek)
                    Text(Shared.Trends.lastMonth).tag(TrendsTimeInterval.lastMonth)
                    Text(Shared.Trends.year2024).tag(TrendsTimeInterval.year2024)
                    Text(Shared.Trends.year2023).tag(TrendsTimeInterval.year2023)
                    Text(Shared.Trends.year2022).tag(TrendsTimeInterval.year2022)
                    Text(Shared.Trends.allTime).tag(TrendsTimeInterval.allTime)
                }
            } label: {
                Label(dropDownText, systemImage: "chevron.up.chevron.down")
            }
//            .onReceive(trendsHelper.$timeIntervalToGoTo) { timeIntervalToGoTo in
//                if let option = timeIntervalToGoTo {
//                    DispatchQueue.main.async {
//                        viewModel.timeIntervalOption = option
//                    }
//                }
//            }
        }
    }

    struct ReactionsRankingView: View {

        let title: String
        let state: LoadingState<[TopChartReaction]>
        let lastUpdatedDate: Date
        let navigateToAction: (String) -> Void
        let reloadAction: () -> Void

        @State private var columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
        //@Environment(\.sizeCategory) var sizeCategory

        var body: some View {
            VStack {
                HStack {
                    Text(title)
                        .font(.title2)
                    Spacer()
                }
                .padding(.horizontal)

                switch state {
                case .loading:
                    LoadingView()

                case .loaded(let items):
                    LazyVGrid(
                        columns: columns,
                        spacing: UIDevice.isiPhone ? 12 : 20
                    ) {
                        ForEach(items) { item in
                            RankedReactionItem(
                                item: item
                            )
                            .onTapGesture {
                                navigateToAction(item.reaction.id)
                            }
                        }
                    }
                    .padding()

                case .error(let errorMessage):
                    ErrorView(
                        message: errorMessage,
                        retryAction: reloadAction
                    )
                }


            }
        }
    }

    struct RankedReactionItem: View {

        let item: TopChartReaction

        var body: some View {
            VStack(spacing: 15) {
                ReactionItem(reaction: item.reaction.reaction)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility2)

                Text(item.description)
                    .bold()
                    .multilineTextAlignment(.center)
            }
        }
    }

    struct NoDataToDisplayView: View {

        var body: some View {
            HStack {
                Spacer()

                VStack(spacing: 10) {
                    Text("Sem Dados para o Período Selecionado")
                        .font(.headline)
                        .padding(.vertical, 40)
                }

                Spacer()
            }
        }
    }

    struct LoadingView: View {

        var body: some View {
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.3, anchor: .center)

                Text("CONTANDO CANALHICES")
                    .foregroundColor(.gray)
                    .font(.callout)
            }
            .padding(.vertical, 100)
        }
    }

    struct ErrorView: View {

        let message: String
        let retryAction: () -> Void

        var body: some View {
            HStack {
                Spacer()

                VStack(spacing: 30) {
                    Text("Não Foi Possível Obter os Dados Mais Recentes")
                        .font(.headline)
                        .multilineTextAlignment(.center)

                    Text(message)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.gray)

                    Button {
                        retryAction()
                    } label: {
                        Label("Tentar Novamente", systemImage: "arrow.clockwise")
                    }
                    .borderedButton(colored: .accentColor)
                }

                Spacer()
            }
            .padding(.vertical, 30)
        }
    }
}

// MARK: - Preview

#Preview {
    MostSharedByAudienceView(
        viewModel: .init(),
        tabSelection: .constant(.trends),
        activePadScreen: .constant(.trends)
    )
}

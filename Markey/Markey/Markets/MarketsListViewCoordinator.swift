//
//  MarketsListViewCoordinator.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//

import LightstreamerClient

final class MarketsListViewCoordinator {
    func instantiate() -> MarketsListView {
        return MarketsListView(viewModel: Self.createViewModel())
    }

    static func createViewModel() -> MarketsListViewModel {
        let lsConfiguration = LSConfiguration()
        let lightstreamerClient = LightstreamerClient(serverAddress: lsConfiguration.clientConfig.endpoint,
                                                      adapterSet: lsConfiguration.clientConfig.adapterSet)
        let streamingService = DataStreamingService(client: lightstreamerClient)
        let dataProvider = MarketStreamingDataProvider(streamingService: streamingService)
        return MarketsListViewModel(streamingDataProvider: dataProvider)
    }
}

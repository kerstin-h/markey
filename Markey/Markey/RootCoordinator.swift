//
//  RootCoordinator.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//

import SwiftUI
import LightstreamerClient

final class RootCoordinator {
    func instantiate() -> MarketsListView {
        MarketsListView(viewModel: Self.createViewModel())
    }

    static func createViewModel() -> MarketsListViewModel {
        let streamingService = configureStreaming()
        let dataProvider = MarketStreamingDataProvider(streamingService: streamingService)
        let dataFormatter = DataFormatter()
        return MarketsListViewModel(dataFormatter: dataFormatter,
                                    streamingDataProvider: dataProvider)
    }
    
    private static func configureStreaming() -> DataStreamingServiceProtocol {
        let lsConfiguration = LSConfiguration()
        let lightstreamerClient = LightstreamerClient(serverAddress: lsConfiguration.clientConfig.endpoint,
                                                      adapterSet: lsConfiguration.clientConfig.adapterSet)
        return DataStreamingService(client: lightstreamerClient)
    }
}

//
//  MarketsListViewModelTests.swift
//  MarkeyTests
//
//  Created by Kerstin Haustein on 11/09/2025.
//

import Testing
@testable import Markey

struct MarketsListViewModelTests {

    // MARK: Test helpers
    
    private func viewModel(dataProvider: LightstreamerDataProvider = LightstreamerDataProviderTestable()) -> MarketsListViewModel {
        return MarketsListViewModel(streamingDataProvider: dataProvider)
    }
    
    // MARK: Tests

    @Test func initViewModelConfiguresStreaming() async throws {
        let dataProvider = LightstreamerDataProviderTestable()
        let viewModel = viewModel(dataProvider: dataProvider)
        #expect(viewModel.markets.count == 0)
    }
}

private final class LightstreamerDataProviderTestable: LightstreamerDataProvider {
    override func lightstreamerClient(serverAddress: String, adapterSet: String) -> any LightstreamerClientProtocol {
        LightstreamerClientMock(serverAddress: serverAddress, adapterSet: adapterSet)
    }
}
